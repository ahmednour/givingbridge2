import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
  static const int imageQuality = 85;

  /// Compress and resize image to optimize for upload
  static Future<File> compressImage(File imageFile) async {
    try {
      // Read image bytes
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Decode image
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate new dimensions while maintaining aspect ratio
      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (originalImage.width > maxImageWidth ||
          originalImage.height > maxImageHeight) {
        final double aspectRatio = originalImage.width / originalImage.height;

        if (originalImage.width > originalImage.height) {
          newWidth = maxImageWidth;
          newHeight = (maxImageWidth / aspectRatio).round();
        } else {
          newHeight = maxImageHeight;
          newWidth = (maxImageHeight * aspectRatio).round();
        }
      }

      // Resize image if needed
      img.Image resizedImage = originalImage;
      if (newWidth != originalImage.width ||
          newHeight != originalImage.height) {
        resizedImage = img.copyResize(
          originalImage,
          width: newWidth,
          height: newHeight,
          interpolation: img.Interpolation.average,
        );
      }

      // Encode image with compression
      final List<int> compressedBytes = img.encodeJpg(
        resizedImage,
        quality: imageQuality,
      );

      // Create temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File compressedFile = File(path.join(tempDir.path, fileName));

      // Write compressed image to file
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      throw Exception('Failed to compress image: ${e.toString()}');
    }
  }

  /// Compress multiple images
  static Future<List<File>> compressImages(List<File> imageFiles) async {
    final List<File> compressedImages = [];

    for (final File imageFile in imageFiles) {
      try {
        final File compressedImage = await compressImage(imageFile);
        compressedImages.add(compressedImage);
      } catch (e) {
        // Log error but continue with other images
        debugPrint(
            'Failed to compress image ${imageFile.path}: ${e.toString()}');
      }
    }

    return compressedImages;
  }

  /// Validate image file
  static Future<bool> validateImage(File imageFile) async {
    try {
      // Check file size
      final int fileSize = await imageFile.length();
      if (fileSize > maxImageSize) {
        return false;
      }

      // Check if file is a valid image
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      return image != null;
    } catch (e) {
      return false;
    }
  }

  /// Get image file size in MB
  static Future<double> getImageSizeInMB(File imageFile) async {
    final int fileSize = await imageFile.length();
    return fileSize / (1024 * 1024);
  }

  /// Get image dimensions
  static Future<Map<String, int>> getImageDimensions(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      throw Exception('Failed to get image dimensions: ${e.toString()}');
    }
  }

  /// Create thumbnail for image
  static Future<File> createThumbnail(File imageFile, {int size = 200}) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Create square thumbnail
      final img.Image thumbnail = img.copyResizeCropSquare(
        originalImage,
        size: size,
        interpolation: img.Interpolation.average,
      );

      // Encode thumbnail
      final List<int> thumbnailBytes = img.encodeJpg(
        thumbnail,
        quality: 80,
      );

      // Create temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName =
          'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File thumbnailFile = File(path.join(tempDir.path, fileName));

      // Write thumbnail to file
      await thumbnailFile.writeAsBytes(thumbnailBytes);

      return thumbnailFile;
    } catch (e) {
      throw Exception('Failed to create thumbnail: ${e.toString()}');
    }
  }

  /// Clean up temporary files
  static Future<void> cleanupTempFiles(List<File> files) async {
    for (final File file in files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint(
            'Failed to delete temporary file ${file.path}: ${e.toString()}');
      }
    }
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Check if file is a supported image format
  static bool isSupportedImageFormat(String filePath) {
    final String extension = getFileExtension(filePath);
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']
        .contains(extension);
  }

  /// Generate unique filename
  static String generateUniqueFilename(String originalFilename) {
    final String extension = getFileExtension(originalFilename);
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String random =
        (timestamp.hashCode % 10000).toString().padLeft(4, '0');
    return 'donation_${timestamp}_${random}$extension';
  }
}
