// lib/features/branch_info/data/models/gallery_photo_model.dart

import 'package:achaytablereservation/core/errors/exceptions.dart';

/// Model representing a gallery photo from the server
class GalleryPhoto {
  final int photoId;
  final String fileName;
  final String fileUrl;
  final int fileSize;
  final bool isPrimary;
  final DateTime uploadedAt;

  const GalleryPhoto({
    required this.photoId,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.isPrimary,
    required this.uploadedAt,
  });

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    try {
      return GalleryPhoto(
        photoId: json['photoId'] as int,
        fileName: json['fileName'] as String,
        fileUrl: json['fileUrl'] as String,
        fileSize: json['fileSize'] as int,
        isPrimary: json['isPrimary'] as bool,
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse GalleryPhoto from JSON: ${e.toString()}',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'photoId': photoId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'isPrimary': isPrimary,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  /// Check if this is a video file based on extension
  bool get isVideo {
    final extension = fileName.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension);
  }

  /// Check if this is an image file based on extension
  bool get isImage {
    final extension = fileName.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  /// Get formatted file size (KB, MB)
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GalleryPhoto && other.photoId == photoId;
  }

  @override
  int get hashCode => photoId.hashCode;

  @override
  String toString() {
    return 'GalleryPhoto(photoId: $photoId, fileName: $fileName, isPrimary: $isPrimary)';
  }
}

/// Response wrapper for gallery API
class GalleryResponse {
  final List<GalleryPhoto> photos;

  const GalleryResponse({required this.photos});

  factory GalleryResponse.fromJson(Map<String, dynamic> json) {
    try {
      final dataList = json['data'] as List<dynamic>;
      final photos = dataList
          .map((item) => GalleryPhoto.fromJson(item as Map<String, dynamic>))
          .toList();
      return GalleryResponse(photos: photos);
    } catch (e) {
      throw ParsingException(
        'Failed to parse GalleryResponse from JSON: ${e.toString()}',
      );
    }
  }

  /// Get the primary photo if exists
  GalleryPhoto? get primaryPhoto {
    try {
      return photos.firstWhere((photo) => photo.isPrimary);
    } catch (e) {
      return photos.isNotEmpty ? photos.first : null;
    }
  }

  /// Get only image files
  List<GalleryPhoto> get images =>
      photos.where((photo) => photo.isImage).toList();

  /// Get only video files
  List<GalleryPhoto> get videos =>
      photos.where((photo) => photo.isVideo).toList();
}
