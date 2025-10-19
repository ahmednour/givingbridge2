import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/design_system.dart';
import 'gb_button.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Multiple Image Upload Widget with Preview Grid for GivingBridge
class GBMultipleImageUpload extends StatefulWidget {
  final Function(List<XFile>) onImagesChanged;
  final String? label;
  final String? helperText;
  final double maxSizeMB;
  final int maxImages;
  final List<String> allowedExtensions;
  final List<XFile>? initialImages;
  final double imageHeight;

  const GBMultipleImageUpload({
    Key? key,
    required this.onImagesChanged,
    this.label,
    this.helperText,
    this.maxSizeMB = 5.0,
    this.maxImages = 6,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'webp'],
    this.initialImages,
    this.imageHeight = 180,
  }) : super(key: key);

  @override
  State<GBMultipleImageUpload> createState() => _GBMultipleImageUploadState();
}

class _GBMultipleImageUploadState extends State<GBMultipleImageUpload> {
  late List<XFile> _images;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _images = widget.initialImages ?? [];
  }

  Future<void> _pickImages() async {
    if (_images.length >= widget.maxImages) {
      _showError('Maximum ${widget.maxImages} images allowed');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (images.isNotEmpty) {
        // Validate file size and extension
        List<XFile> validImages = [];
        for (final image in images) {
          final bytes = await image.readAsBytes();
          final sizeMB = bytes.length / (1024 * 1024);

          if (sizeMB > widget.maxSizeMB) {
            _showError('${image.name}: Image exceeds ${widget.maxSizeMB}MB');
            continue;
          }

          final extension = image.path.split('.').last.toLowerCase();
          if (!widget.allowedExtensions.contains(extension)) {
            _showError(
                '${image.name}: Only ${widget.allowedExtensions.join(', ')} allowed');
            continue;
          }

          validImages.add(image);

          // Check max images limit
          if (_images.length + validImages.length >= widget.maxImages) {
            _showError('Maximum ${widget.maxImages} images allowed');
            break;
          }
        }

        if (validImages.isNotEmpty) {
          setState(() {
            _images.addAll(validImages);
          });
          widget.onImagesChanged(_images);
        }
      }
    } catch (e) {
      _showError('Failed to pick images: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _takePhoto() async {
    if (_images.length >= widget.maxImages) {
      _showError('Maximum ${widget.maxImages} images allowed');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final sizeMB = bytes.length / (1024 * 1024);

        if (sizeMB > widget.maxSizeMB) {
          _showError('Image size exceeds ${widget.maxSizeMB}MB limit');
          setState(() => _isUploading = false);
          return;
        }

        setState(() {
          _images.add(image);
        });
        widget.onImagesChanged(_images);
      }
    } catch (e) {
      _showError('Failed to take photo: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
    widget.onImagesChanged(_images);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignSystem.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DesignSystem.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  color: DesignSystem.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: DesignSystem.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label!,
                      style: DesignSystem.titleMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.helperText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.helperText!,
                        style: DesignSystem.bodySmall(context).copyWith(
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSystem.spaceL),
        ],

        // Upload Buttons
        Container(
          padding: const EdgeInsets.all(DesignSystem.spaceL),
          decoration: BoxDecoration(
            color: DesignSystem.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
            border: Border.all(
              color: DesignSystem.getBorderColor(context),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _images.isEmpty ? 'Add Images' : 'Add More Images',
                style: DesignSystem.titleSmall(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: DesignSystem.spaceM),

              // Button Row
              Row(
                children: [
                  Expanded(
                    child: GBSecondaryButton(
                      text: 'Select from Gallery',
                      leftIcon:
                          const Icon(Icons.photo_library_outlined, size: 20),
                      onPressed: _isUploading ? null : _pickImages,
                      isLoading: _isUploading,
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  Expanded(
                    child: GBSecondaryButton(
                      text: 'Take Photo',
                      leftIcon: const Icon(Icons.camera_alt_outlined, size: 20),
                      onPressed: _isUploading ? null : _takePhoto,
                    ),
                  ),
                ],
              ),

              // Image count info
              if (_images.isNotEmpty) ...[
                const SizedBox(height: DesignSystem.spaceM),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: DesignSystem.textSecondary,
                    ),
                    const SizedBox(width: DesignSystem.spaceS),
                    Text(
                      '${_images.length} of ${widget.maxImages} images selected',
                      style: DesignSystem.bodySmall(context).copyWith(
                        color: DesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Image Preview Grid
        if (_images.isNotEmpty) ...[
          const SizedBox(height: DesignSystem.spaceL),
          Text(
            'Selected Images',
            style: DesignSystem.titleSmall(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceM),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: DesignSystem.spaceM,
              mainAxisSpacing: DesignSystem.spaceM,
              childAspectRatio: 1,
            ),
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return _buildImagePreview(index);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildImagePreview(int index) {
    final xFile = _images[index];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: DesignSystem.getBorderColor(context),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            kIsWeb
                ? FutureBuilder<Uint8List>(
                    future: xFile.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      }
                      return Container(
                        color: DesignSystem.neutral100,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: DesignSystem.primaryBlue,
                          ),
                        ),
                      );
                    },
                  )
                : Image.network(
                    xFile.path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: DesignSystem.neutral100,
                        child: Icon(
                          Icons.broken_image,
                          color: DesignSystem.neutral400,
                          size: 32,
                        ),
                      );
                    },
                  ),

            // Delete button overlay
            Positioned(
              top: DesignSystem.spaceS,
              right: DesignSystem.spaceS,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),

            // Image number badge
            Positioned(
              bottom: DesignSystem.spaceS,
              left: DesignSystem.spaceS,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
