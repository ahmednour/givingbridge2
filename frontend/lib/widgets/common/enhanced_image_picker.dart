import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme_enhanced.dart';
import '../../core/constants/ui_constants.dart';
import '../../widgets/common/gb_button.dart';
import '../../services/image_upload_service.dart';
import '../../l10n/app_localizations.dart';

class EnhancedImagePicker extends StatefulWidget {
  final List<File> selectedImages;
  final Function(List<File>) onImagesChanged;
  final int maxImages;
  final bool allowCamera;
  final bool allowGallery;
  final double imageSize;
  final int crossAxisCount;
  final bool showImageCount;
  final bool showImageSize;
  final bool enableCompression;
  final String? errorMessage;

  const EnhancedImagePicker({
    Key? key,
    required this.selectedImages,
    required this.onImagesChanged,
    this.maxImages = 5,
    this.allowCamera = true,
    this.allowGallery = true,
    this.imageSize = 100.0,
    this.crossAxisCount = 3,
    this.showImageCount = true,
    this.showImageSize = false,
    this.enableCompression = true,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<EnhancedImagePicker> createState() => _EnhancedImagePickerState();
}

class _EnhancedImagePickerState extends State<EnhancedImagePicker> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _pickImages() async {
    if (!widget.allowGallery) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        await _processImages(images);
      }
    } catch (e) {
      _showErrorSnackbar('Error picking images: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    if (!widget.allowCamera) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImages([image]);
      }
    } catch (e) {
      _showErrorSnackbar('Error taking photo: ${e.toString()}');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processImages(List<XFile> images) async {
    final List<File> newImages = [];

    for (final XFile image in images) {
      try {
        // Check if we've reached the maximum number of images
        if (widget.selectedImages.length + newImages.length >=
            widget.maxImages) {
          _showErrorSnackbar('Maximum ${widget.maxImages} images allowed');
          break;
        }

        final File imageFile = File(image.path);

        // Validate image
        final bool isValid = await ImageUploadService.validateImage(imageFile);
        if (!isValid) {
          _showErrorSnackbar('Invalid image: ${image.name}');
          continue;
        }

        // Compress image if enabled
        final File processedImage = widget.enableCompression
            ? await ImageUploadService.compressImage(imageFile)
            : imageFile;

        newImages.add(processedImage);
      } catch (e) {
        _showErrorSnackbar('Failed to process image: ${e.toString()}');
      }
    }

    if (newImages.isNotEmpty) {
      widget.onImagesChanged([...widget.selectedImages, ...newImages]);
    }
  }

  void _removeImage(int index) {
    final List<File> updatedImages = List.from(widget.selectedImages);
    updatedImages.removeAt(index);
    widget.onImagesChanged(updatedImages);
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: UIConstants.spacingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
        margin: EdgeInsets.all(UIConstants.spacingM),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.donationImages,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (widget.showImageCount)
              Text(
                '${widget.selectedImages.length}/${widget.maxImages}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
          ],
        ),

        SizedBox(height: UIConstants.spacingM),

        // Image Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            crossAxisSpacing: UIConstants.spacingS,
            mainAxisSpacing: UIConstants.spacingS,
            childAspectRatio: 1,
          ),
          itemCount: widget.selectedImages.length + 1,
          itemBuilder: (context, index) {
            if (index == widget.selectedImages.length) {
              // Add Image Button
              return _buildAddImageButton();
            } else {
              // Image Thumbnail
              return _buildImageThumbnail(index);
            }
          },
        ),

        // Error Message
        if (widget.errorMessage != null) ...[
          SizedBox(height: UIConstants.spacingS),
          Text(
            widget.errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.errorColor,
                ),
          ),
        ],

        // Upload Options (if no images selected)
        if (widget.selectedImages.isEmpty) ...[
          SizedBox(height: UIConstants.spacingM),
          Row(
            children: [
              if (widget.allowGallery)
                Expanded(
                  child: GBButton(
                    text: l10n.selectFromGallery,
                    leftIcon: Icon(Icons.photo_library_outlined),
                    variant: GBButtonVariant.secondary,
                    onPressed: _isProcessing ? null : _pickImages,
                    isLoading: _isProcessing,
                  ),
                ),
              if (widget.allowGallery && widget.allowCamera)
                SizedBox(width: UIConstants.spacingM),
              if (widget.allowCamera)
                Expanded(
                  child: GBButton(
                    text: l10n.takePhoto,
                    leftIcon: Icon(Icons.camera_alt_outlined),
                    variant: GBButtonVariant.secondary,
                    onPressed: _isProcessing ? null : _takePhoto,
                    isLoading: _isProcessing,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAddImageButton() {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _isProcessing ? null : () => _showImageSourceDialog(),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
          border: Border.all(
            color: AppTheme.borderColor,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: UIConstants.spacingXS),
            Text(
              l10n.addImage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(int index) {
    final File imageFile = widget.selectedImages[index];

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(UIConstants.radiusM),
            image: DecorationImage(
              image: FileImage(imageFile),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Remove Button
        Positioned(
          top: UIConstants.spacingXS,
          right: UIConstants.spacingXS,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: EdgeInsets.all(UIConstants.spacingXS),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),

        // Image Info (if enabled)
        if (widget.showImageSize)
          Positioned(
            bottom: UIConstants.spacingXS,
            left: UIConstants.spacingXS,
            right: UIConstants.spacingXS,
            child: FutureBuilder<double>(
              future: ImageUploadService.getImageSizeInMB(imageFile),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: UIConstants.spacingXS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(UIConstants.radiusS),
                    ),
                    child: Text(
                      '${snapshot.data!.toStringAsFixed(1)}MB',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
      ],
    );
  }

  void _showImageSourceDialog() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UIConstants.radiusL),
        ),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(UIConstants.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            SizedBox(height: UIConstants.spacingL),

            Text(
              l10n.selectImageSource,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            SizedBox(height: UIConstants.spacingL),

            Row(
              children: [
                if (widget.allowGallery)
                  Expanded(
                    child: GBButton(
                      text: l10n.selectFromGallery,
                      leftIcon: Icon(Icons.photo_library_outlined),
                      variant: GBButtonVariant.secondary,
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImages();
                      },
                    ),
                  ),
                if (widget.allowGallery && widget.allowCamera)
                  SizedBox(width: UIConstants.spacingM),
                if (widget.allowCamera)
                  Expanded(
                    child: GBButton(
                      text: l10n.takePhoto,
                      leftIcon: Icon(Icons.camera_alt_outlined),
                      variant: GBButtonVariant.secondary,
                      onPressed: () {
                        Navigator.pop(context);
                        _takePhoto();
                      },
                    ),
                  ),
              ],
            ),

            SizedBox(height: UIConstants.spacingL),
          ],
        ),
      ),
    );
  }
}

class ImagePreviewDialog extends StatelessWidget {
  final File imageFile;
  final String? title;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const ImagePreviewDialog({
    Key? key,
    required this.imageFile,
    this.title,
    this.onDelete,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            if (title != null)
              Padding(
                padding: EdgeInsets.all(UIConstants.spacingL),
                child: Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),

            // Image
            Flexible(
              child: InteractiveViewer(
                child: Image.file(
                  imageFile,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Actions
            if (onDelete != null || onEdit != null)
              Padding(
                padding: EdgeInsets.all(UIConstants.spacingL),
                child: Row(
                  children: [
                    if (onEdit != null)
                      Expanded(
                        child: GBButton(
                          text: l10n.edit,
                          leftIcon: Icon(Icons.edit_outlined),
                          variant: GBButtonVariant.secondary,
                          onPressed: onEdit,
                        ),
                      ),
                    if (onEdit != null && onDelete != null)
                      SizedBox(width: UIConstants.spacingM),
                    if (onDelete != null)
                      Expanded(
                        child: GBButton(
                          text: l10n.delete,
                          leftIcon: Icon(Icons.delete_outlined),
                          variant: GBButtonVariant.secondary,
                          onPressed: onDelete,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
