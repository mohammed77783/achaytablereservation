// lib/features/branch_info/presentation/controllers/media_viewer_controller.dart

import 'package:flutter/material.dart';
import 'package:achaytablereservation/features/homepage/data/model/gallery_photo_model.dart';

/// Controller for MediaViewer widget
class MediaViewerController extends ChangeNotifier {
  final List<GalleryPhoto> items;
  final int initialIndex;
  final VoidCallback? onClose;
  late PageController pageController;
  int _currentIndex;
  MediaViewerController({
    required this.items,
    required this.initialIndex,
    this.onClose,
  }) : _currentIndex = initialIndex {
    pageController = PageController(initialPage: initialIndex);
  }

  /// Current index in the gallery
  int get currentIndex => _currentIndex;

  /// Current item being displayed
  GalleryPhoto get currentItem => items[_currentIndex];

  /// Total number of items
  int get totalItems => items.length;

  /// Display string for counter (e.g., "1 / 10")
  String get counterText => '${_currentIndex + 1} / $totalItems';

  /// Whether there's a previous item
  bool get hasPrevious => _currentIndex > 0;

  /// Whether there's a next item
  bool get hasNext => _currentIndex < items.length - 1;

  /// Called when page changes
  void onPageChanged(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Navigate to previous item
  void previousPage() {
    if (hasPrevious) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigate to next item
  void nextPage() {
    if (hasNext) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Jump to specific index
  void jumpToPage(int index) {
    if (index >= 0 && index < items.length) {
      pageController.jumpToPage(index);
    }
  }

  /// Animate to specific index
  void animateToPage(int index) {
    if (index >= 0 && index < items.length) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Close the viewer
  void close() {
    onClose?.call();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
