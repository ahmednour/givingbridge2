import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/design_system.dart';
import 'gb_button.dart';

/// Image Upload Widget with Drag & Drop, Preview for GivingBridge
class GBImageUpload extends StatefulWidget {
  final Function(Uint8List?, String?) onImageSelected;
  final String? label;
  final String? helperText;
  final double maxSizeMB;
  final List<String> allowedExtensions;
  final double? width;
  final double? height;
  final Uint8List? initialImage;
  final String? imageUrl;

  const GBImageUpload({
    Key? key,
    required this.onImageSelected,
    this.label,
    this.helperText,
    this.maxSizeMB = 5.0,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'webp'],
    this.width,
    this.height,
    this.initialImage,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<GBImageUpload> createState() => _GBImageUploadState();
}

class _GBImageUploadState extends State<GBImageUpload> {
  Uint8List? _imageData;
  String? _imageName;
  bool _isDragging = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageData = widget.initialImage;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final sizeMB = bytes.length / (1024 * 1024);

        if (sizeMB > widget.maxSizeMB) {
          _showError('Image size exceeds ${widget.maxSizeMB}MB limit');
          return;
        }

        final extension = image.path.split('.').last.toLowerCase();
        if (!widget.allowedExtensions.contains(extension)) {
          _showError(
              'Only ${widget.allowedExtensions.join(', ')} files allowed');
          return;
        }

        setState(() {
          _imageData = bytes;
          _imageName = image.name;
        });

        widget.onImageSelected(bytes, image.name);
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _imageData = null;
      _imageName = null;
    });
    widget.onImageSelected(null, null);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignSystem.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: DesignSystem.labelLarge(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceM),
        ],

        // Upload area
        GestureDetector(
          onTap: _imageData == null ? _pickImage : null,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isDragging = true),
            onExit: (_) => setState(() => _isDragging = false),
            child: AnimatedContainer(
              duration: DesignSystem.shortDuration,
              width: widget.width ?? double.infinity,
              height: widget.height ?? 200,
              decoration: BoxDecoration(
                color: _imageData != null
                    ? Colors.black
                    : (_isDragging
                        ? DesignSystem.primaryBlue.withOpacity(0.05)
                        : DesignSystem.getSurfaceColor(context)),
                borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                border: Border.all(
                  color: _isDragging
                      ? DesignSystem.primaryBlue
                      : DesignSystem.getBorderColor(context),
                  width: _isDragging ? 2 : 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child:
                  _imageData != null ? _buildPreview() : _buildUploadPrompt(),
            ),
          ),
        ),

        // Helper text
        if (widget.helperText != null || _imageName != null) ...[
          const SizedBox(height: DesignSystem.spaceS),
          Text(
            _imageName ?? widget.helperText ?? '',
            style: DesignSystem.bodySmall(context),
          ),
        ],

        // Action buttons (when image is selected)
        if (_imageData != null) ...[
          const SizedBox(height: DesignSystem.spaceM),
          Row(
            children: [
              Expanded(
                child: GBOutlineButton(
                  text: 'Change Image',
                  onPressed: _pickImage,
                  size: GBButtonSize.small,
                  leftIcon: const Icon(Icons.edit),
                ),
              ),
              const SizedBox(width: DesignSystem.spaceM),
              Expanded(
                child: GBButton(
                  text: 'Remove',
                  variant: GBButtonVariant.danger,
                  size: GBButtonSize.small,
                  onPressed: _removeImage,
                  leftIcon: const Icon(Icons.delete_outline),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignSystem.radiusL),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(
            _imageData!,
            fit: BoxFit.cover,
          ),
          // Overlay with actions
          Positioned(
            top: DesignSystem.spaceM,
            right: DesignSystem.spaceM,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: _pickImage,
                    iconSize: 20,
                    tooltip: 'Change image',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: _removeImage,
                    iconSize: 20,
                    tooltip: 'Remove image',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: (_isDragging
                    ? DesignSystem.primaryBlue
                    : DesignSystem.neutral300)
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Icon(
            Icons.cloud_upload_outlined,
            size: 32,
            color: _isDragging
                ? DesignSystem.primaryBlue
                : DesignSystem.textSecondary,
          ),
        ),
        const SizedBox(height: DesignSystem.spaceL),
        Text(
          'Click to upload or drag and drop',
          style: DesignSystem.bodyMedium(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DesignSystem.spaceS),
        Text(
          '${widget.allowedExtensions.join(', ').toUpperCase()} (max ${widget.maxSizeMB}MB)',
          style: DesignSystem.bodySmall(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Usage Examples:
/// 
/// GBImageUpload(
///   label: 'Donation Image',
///   helperText: 'Upload a clear photo of the item',
///   maxSizeMB: 5.0,
///   onImageSelected: (bytes, name) {
///     setState(() {
///       _imageData = bytes;
///       _imageName = name;
///     });
///   },
/// )
/// 
/// // With initial image
/// GBImageUpload(
///   label: 'Profile Picture',
///   initialImage: _existingImageBytes,
///   width: 200,
///   height: 200,
///   onImageSelected: (bytes, name) => _updateProfile(bytes),
/// )
