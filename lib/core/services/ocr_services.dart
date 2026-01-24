import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Simple data class for card info
class CardData {
  final String cardNumber;
  final String expirationDate;

  CardData({
    this.cardNumber = '',
    this.expirationDate = '',
  });

  bool get isComplete => cardNumber.length >= 15 && expirationDate.isNotEmpty;
  bool get hasCardNumber => cardNumber.length >= 15;
  
  String get formattedCardNumber {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

/// Simple Card OCR Scanner
class CardScanner {
  CameraController? cameraController;
  
  final TextRecognizer _textRecognizer = TextRecognizer();
  Timer? _scanTimer;
  bool _isCapturing = false;
  bool _isScanning = false;

  // Callbacks
  void Function(CardData data)? onResult;
  void Function(String status)? onStatus;
  void Function(String error)? onError;

  bool get isInitialized => cameraController?.value.isInitialized ?? false;
  bool get isScanning => _isScanning;

  /// Initialize camera
  Future<bool> initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        onError?.call('No camera available');
        return false;
      }

      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await cameraController!.initialize();
      await cameraController!.setFlashMode(FlashMode.off);
      await cameraController!.setFocusMode(FocusMode.auto);
      return true;
    } catch (e) {
      onError?.call('Camera init failed: $e');
      return false;
    }
  }

  /// Start live scanning
  Future<void> startScan() async {
    if (!isInitialized) {
      final success = await initCamera();
      if (!success) return;
    }

    _isScanning = true;
    onStatus?.call('Scanning... align card');

    // Scan every 1.5 seconds
    _scanTimer = Timer.periodic(
      const Duration(milliseconds: 1500),
      (_) => _captureAndProcess(),
    );
    _captureAndProcess(); // immediate first scan
  }

  /// Stop scanning
  void stopScan() {
    _scanTimer?.cancel();
    _scanTimer = null;
    _isScanning = false;
    onStatus?.call('');
  }

  /// Scan from image file path
  Future<CardData> scanImage(String imagePath) async {
    try {
      onStatus?.call('Processing...');
      final inputImage = InputImage.fromFilePath(imagePath);
      final text = await _textRecognizer.processImage(inputImage);
      final data = _extractCardData(text);
      onStatus?.call(data.isComplete ? 'Card found!' : 'Partial data');
      return data;
    } catch (e) {
      onError?.call('Scan failed: $e');
      return CardData();
    }
  }

  /// Capture and process (internal)
  Future<void> _captureAndProcess() async {
    if (_isCapturing || !_isScanning || !isInitialized) return;
    
    _isCapturing = true;
    try {
      final image = await cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final text = await _textRecognizer.processImage(inputImage);

      if (text.blocks.isEmpty) {
        onStatus?.call('No text. Move closer.');
      } else {
        final data = _extractCardData(text);
        _handleResult(data);
      }

      // Delete temp file
      try { await File(image.path).delete(); } catch (_) {}
    } catch (e) {
      onStatus?.call('Scanning...');
    } finally {
      _isCapturing = false;
    }
  }

  /// Handle scan result
  void _handleResult(CardData data) {
    if (data.hasCardNumber) {
      onResult?.call(data);
      if (data.isComplete) {
        onStatus?.call('✓ Card captured!');
        Future.delayed(const Duration(milliseconds: 500), stopScan);
      } else {
        onStatus?.call('✓ Number found! Looking for expiry...');
      }
    }
  }

  /// Extract card data from OCR text
  CardData _extractCardData(RecognizedText text) {
    String cardNumber = '';
    String expiration = '';
    List<String> fourDigitGroups = [];

    for (final block in text.blocks) {
      for (final line in block.lines) {
        final raw = line.text;
        final clean = raw.replaceAll(' ', '').replaceAll('-', '');

        // 1. Find 16-digit number
        if (cardNumber.isEmpty) {
          final match = RegExp(r'\d{15,16}').firstMatch(clean);
          if (match != null) {
            cardNumber = match.group(0)!.substring(0, 16);
          }
        }

        // 2. Find spaced card number (1234 5678 9012 3456)
        if (cardNumber.isEmpty) {
          final match = RegExp(r'(\d{4}[\s\-]?){3,4}\d{1,4}').firstMatch(raw);
          if (match != null) {
            final num = match.group(0)!.replaceAll(RegExp(r'[\s\-]'), '');
            if (num.length >= 15 && num.length <= 16) cardNumber = num;
          }
        }

        // 3. Collect 4-digit groups
        if (cardNumber.isEmpty) {
          final matches = RegExp(r'\b(\d{4})\b').allMatches(raw);
          for (final m in matches) {
            final g = m.group(1)!;
            if (!fourDigitGroups.contains(g) &&
                !raw.contains('/') &&
                !raw.toUpperCase().contains('EXP')) {
              fourDigitGroups.add(g);
            }
          }
        }

        // 4. Find expiration (MM/YY or MM/YYYY)
        if (expiration.isEmpty) {
          final match = RegExp(r'(0[1-9]|1[0-2])\s?[/\-]\s?(\d{2}|\d{4})').firstMatch(raw);
          if (match != null) {
            expiration = _normalizeExpiration(match.group(0)!);
          }
        }

        // 5. Check VALID THRU pattern
        if (expiration.isEmpty && 
            (raw.toUpperCase().contains('VALID') || raw.toUpperCase().contains('EXP'))) {
          final match = RegExp(r'(\d{2})[/\-](\d{2,4})').firstMatch(raw);
          if (match != null) {
            String year = match.group(2)!;
            if (year.length == 4) year = year.substring(2);
            expiration = '${match.group(1)}/$year';
          }
        }
      }
    }

    // Combine 4-digit groups if no card number found
    if (cardNumber.isEmpty && fourDigitGroups.length >= 4) {
      final combined = fourDigitGroups.take(4).join('');
      if (combined.length == 16) cardNumber = combined;
    }

    return CardData(cardNumber: cardNumber, expirationDate: expiration);
  }

  /// Normalize expiration to MM/YY
  String _normalizeExpiration(String exp) {
    exp = exp.replaceAll(' ', '');
    if (exp.length > 5) {
      final parts = exp.split(RegExp(r'[/\-]'));
      if (parts.length == 2) {
        String year = parts[1];
        if (year.length == 4) year = year.substring(2);
        return '${parts[0]}/$year';
      }
    }
    return exp;
  }

  /// Dispose resources
  void dispose() {
    stopScan();
    _textRecognizer.close();
    cameraController?.dispose();
  }
}