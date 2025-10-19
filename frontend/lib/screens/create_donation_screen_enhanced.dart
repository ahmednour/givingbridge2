import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme_enhanced.dart';
import '../core/utils/rtl_utils.dart';
import '../core/constants/ui_constants.dart';
import '../core/constants/donation_constants.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/app_components.dart';
import '../providers/donation_provider.dart';
import '../models/donation.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CreateDonationScreenEnhanced extends StatefulWidget {
  final Donation? donation;

  const CreateDonationScreenEnhanced({
    Key? key,
    this.donation,
  }) : super(key: key);

  @override
  State<CreateDonationScreenEnhanced> createState() =>
      _CreateDonationScreenEnhancedState();
}

class _CreateDonationScreenEnhancedState
    extends State<CreateDonationScreenEnhanced> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  // State variables
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isPickingImages = false;
  String _selectedCategory = DonationCategory.values.first.value;
  String _selectedCondition = DonationCondition.values.first.value;
  List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Animation controllers
  late AnimationController _stepAnimationController;
  late AnimationController _progressAnimationController;

  @override
  void initState() {
    super.initState();

    _initializeAnimations();
    _populateFormFields();
  }

  void _initializeAnimations() {
    _stepAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _stepAnimationController.forward();
    _progressAnimationController.forward();
  }

  void _populateFormFields() {
    // Set default values for new donations
    _quantityController.text = '1'; // Default quantity

    if (widget.donation != null) {
      final donation = widget.donation!;
      _titleController.text = donation.title;
      _descriptionController.text = donation.description;
      _locationController.text = donation.location;
      _selectedCategory = donation.category;
      _selectedCondition = donation.condition;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stepAnimationController.dispose();
    _progressAnimationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Validate form on step 0 (Basic Info step)
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() != true) {
        return; // Don't proceed if validation fails
      }
    }

    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickImages() async {
    setState(() => _isPickingImages = true);

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1200, // Reduced from 1920
        maxHeight: 800, // Reduced from 1080
        imageQuality: 70, // Reduced from 85 for smaller file size
      );

      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      _showErrorSnackbar('Error picking images: ${e.toString()}');
    } finally {
      setState(() => _isPickingImages = false);
    }
  }

  Future<void> _takePhoto() async {
    setState(() => _isPickingImages = true);

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200, // Reduced from 1920
        maxHeight: 800, // Reduced from 1080
        imageQuality: 70, // Reduced from 85
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      _showErrorSnackbar('Error taking photo: ${e.toString()}');
    } finally {
      setState(() => _isPickingImages = false);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitDonation() async {
    // Basic validation - check required fields have values
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty) {
      _showErrorSnackbar(
          AppLocalizations.of(context)!.pleaseFillRequiredFields);
      _goToStep(0);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final donationProvider =
          Provider.of<DonationProvider>(context, listen: false);

      final donation = Donation(
        id: widget.donation?.id ?? 0, // Temporary ID for new donations
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        condition: _selectedCondition,
        location: _locationController.text.trim(),
        donorId: widget.donation?.donorId ?? 0, // Current user ID
        donorName: widget.donation?.donorName ?? 'Current User',
        imageUrl: widget.donation?.imageUrl,
        isAvailable: true, // New donations are available by default
        status: 'available',
        createdAt:
            widget.donation?.createdAt ?? DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      bool success;
      if (widget.donation != null) {
        success = await donationProvider.updateDonation(
          id: donation.id.toString(),
          title: donation.title,
          description: donation.description,
          category: donation.category,
          condition: donation.condition,
          location: donation.location,
          imageUrl: donation.imageUrl,
          isAvailable: donation.isAvailable,
        );
      } else {
        success = await donationProvider.createDonation(
          title: donation.title,
          description: donation.description,
          category: donation.category,
          condition: donation.condition,
          location: donation.location,
          imageUrl: donation.imageUrl,
        );
      }

      if (success) {
        _showSuccessSnackbar(
          widget.donation != null
              ? AppLocalizations.of(context)!.donationUpdated
              : AppLocalizations.of(context)!.donationCreated,
        );
        Navigator.pop(context, true);
      } else {
        _showErrorSnackbar(donationProvider.error ?? 'An error occurred');
      }
    } catch (e) {
      _showErrorSnackbar('Network error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            AppSpacing.horizontal(UIConstants.spacingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
        margin: EdgeInsets.all(UIConstants.spacingM),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            AppSpacing.horizontal(UIConstants.spacingS),
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

  IconData _getCategoryIcon(DonationCategory category) {
    switch (category) {
      case DonationCategory.food:
        return Icons.restaurant;
      case DonationCategory.clothes:
        return Icons.checkroom;
      case DonationCategory.books:
        return Icons.menu_book;
      case DonationCategory.electronics:
        return Icons.devices;
      case DonationCategory.other:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            RTLUtils.getDirectionalIcon(context, Icons.arrow_back,
                start: Icons.arrow_back, end: Icons.arrow_forward),
            color: AppTheme.textPrimaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.donation != null ? l10n.editDonation : l10n.createDonation,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
        ),
        centerTitle: true,
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: Text(
                l10n.previous,
                style: TextStyle(color: AppTheme.primaryColor),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Step Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildBasicInfoStep(),
                _buildCategoryStep(),
                _buildImagesStep(),
                _buildReviewStep(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(UIConstants.spacingM),
      child: Column(
        children: [
          Row(
            children: List.generate(4, (index) {
              final isActive = index <= _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primaryColor
                              : AppTheme.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < 3) AppSpacing.horizontal(UIConstants.spacingXS),
                  ],
                ),
              );
            }),
          ),
          AppSpacing.vertical(UIConstants.spacingS),
          Text(
            '${_currentStep + 1} of 4',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(UIConstants.spacingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(UIConstants.radiusM),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  AppSpacing.horizontal(UIConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.donationDetails,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        AppSpacing.vertical(UIConstants.spacingXS),
                        Text(
                          l10n.basicInfoDescription,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.vertical(UIConstants.spacingL),

            // Form Fields
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  AppTextField(
                    label: l10n.donationTitle,
                    hint: l10n.donationTitleHint,
                    controller: _titleController,
                    isRequired: true,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return l10n.requiredField;
                      }
                      if (value!.length < 3) {
                        return l10n.titleTooShort;
                      }
                      return null;
                    },
                  ),

                  AppSpacing.vertical(UIConstants.spacingM),

                  // Description
                  AppTextField(
                    label: l10n.donationDescription,
                    hint: l10n.donationDescriptionHint,
                    controller: _descriptionController,
                    maxLines: 4,
                    isRequired: true,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return l10n.requiredField;
                      }
                      if (value!.length < 10) {
                        return l10n.descriptionTooShort;
                      }
                      return null;
                    },
                  ),

                  AppSpacing.vertical(UIConstants.spacingM),

                  // Location
                  AppTextField(
                    label: l10n.donationLocation,
                    hint: l10n.donationLocationHint,
                    controller: _locationController,
                    prefixIcon: Icon(Icons.location_on_outlined),
                    isRequired: true,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return l10n.requiredField;
                      }
                      if (value!.length < 2) {
                        return l10n.locationTooShort;
                      }
                      return null;
                    },
                  ),

                  AppSpacing.vertical(UIConstants.spacingM),

                  // Quantity
                  AppTextField(
                    label: l10n.quantity,
                    hint: l10n.quantityHint,
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty == true) {
                        return l10n.requiredField;
                      }
                      final quantity = int.tryParse(value!);
                      if (quantity == null || quantity < 1) {
                        return l10n.invalidQuantity;
                      }
                      return null;
                    },
                  ),

                  AppSpacing.vertical(UIConstants.spacingM),

                  // Notes
                  AppTextField(
                    label: l10n.notes,
                    hint: l10n.notesHint,
                    controller: _notesController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStep() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(UIConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    color: AppTheme.secondaryColor,
                    size: 28,
                  ),
                ),
                AppSpacing.horizontal(UIConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.categoryAndCondition,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      AppSpacing.vertical(UIConstants.spacingXS),
                      Text(
                        l10n.categoryDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.vertical(UIConstants.spacingL),

          // Category Selection
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.donationCategory,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                AppSpacing.vertical(UIConstants.spacingM),
                Wrap(
                  spacing: UIConstants.spacingS,
                  runSpacing: UIConstants.spacingS,
                  children: DonationCategory.values.map((category) {
                    final isSelected = _selectedCategory == category.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category.value;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: UIConstants.spacingM,
                          vertical: UIConstants.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.surfaceColor,
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusM),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondaryColor,
                            ),
                            AppSpacing.horizontal(UIConstants.spacingXS),
                            Text(
                              category.getDisplayName(false),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textPrimaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          AppSpacing.vertical(UIConstants.spacingL),

          // Condition Selection
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.condition,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                AppSpacing.vertical(UIConstants.spacingM),
                Row(
                  children: DonationCondition.values.map((condition) {
                    final isSelected = _selectedCondition == condition.value;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCondition = condition.value;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                            right: UIConstants.spacingXS,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: UIConstants.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(DonationConstants
                                    .conditionColors[condition.value]!)
                                : AppTheme.surfaceColor,
                            borderRadius:
                                BorderRadius.circular(UIConstants.radiusM),
                            border: Border.all(
                              color: isSelected
                                  ? Color(DonationConstants
                                      .conditionColors[condition.value]!)
                                  : AppTheme.borderColor,
                            ),
                          ),
                          child: Text(
                            condition.getDisplayName(false),
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textPrimaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesStep() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(UIConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  ),
                  child: Icon(
                    Icons.photo_camera_outlined,
                    color: AppTheme.accentColor,
                    size: 28,
                  ),
                ),
                AppSpacing.horizontal(UIConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.donationImages,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      AppSpacing.vertical(UIConstants.spacingXS),
                      Text(
                        l10n.imagesDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.vertical(UIConstants.spacingL),

          // Image Upload Options
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addImages,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                AppSpacing.vertical(UIConstants.spacingM),
                Row(
                  children: [
                    Expanded(
                      child: GBSecondaryButton(
                        text: l10n.selectFromGallery,
                        leftIcon:
                            const Icon(Icons.photo_library_outlined, size: 20),
                        onPressed: _pickImages,
                      ),
                    ),
                    AppSpacing.horizontal(UIConstants.spacingM),
                    Expanded(
                      child: GBSecondaryButton(
                        text: l10n.takePhoto,
                        leftIcon:
                            const Icon(Icons.camera_alt_outlined, size: 20),
                        onPressed: _takePhoto,
                      ),
                    ),
                  ],
                ),
                if (_selectedImages.isNotEmpty) ...[
                  AppSpacing.vertical(UIConstants.spacingL),
                  Text(
                    l10n.selectedImages,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  AppSpacing.vertical(UIConstants.spacingM),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: UIConstants.spacingS,
                      mainAxisSpacing: UIConstants.spacingS,
                      childAspectRatio: 1,
                    ),
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      final xFile = _selectedImages[index];
                      return Stack(
                        children: [
                          kIsWeb
                              ? FutureBuilder<Uint8List>(
                                  future: xFile.readAsBytes(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              UIConstants.radiusM),
                                          image: DecorationImage(
                                            image: MemoryImage(snapshot.data!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            UIConstants.radiusM),
                                        color: Colors.grey[300],
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        UIConstants.radiusM),
                                    image: DecorationImage(
                                      image: NetworkImage(xFile.path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
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
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: EdgeInsets.all(UIConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          AppCard(
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.successColor,
                    size: 28,
                  ),
                ),
                AppSpacing.horizontal(UIConstants.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.reviewDonation,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      AppSpacing.vertical(UIConstants.spacingXS),
                      Text(
                        l10n.reviewDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          AppSpacing.vertical(UIConstants.spacingL),

          // Review Content
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Info
                _buildReviewSection(
                  l10n.donationDetails,
                  [
                    _buildReviewItem(l10n.donationTitle, _titleController.text),
                    _buildReviewItem(
                        l10n.donationDescription, _descriptionController.text),
                    _buildReviewItem(
                        l10n.donationLocation, _locationController.text),
                    _buildReviewItem(l10n.quantity, _quantityController.text),
                    if (_notesController.text.isNotEmpty)
                      _buildReviewItem(l10n.notes, _notesController.text),
                  ],
                ),

                AppSpacing.vertical(UIConstants.spacingL),

                // Category and Condition
                _buildReviewSection(
                  l10n.categoryAndCondition,
                  [
                    _buildReviewItem(
                      l10n.donationCategory,
                      DonationCategory.fromString(_selectedCategory)
                          .getDisplayName(false),
                    ),
                    _buildReviewItem(
                      l10n.condition,
                      DonationCondition.fromString(_selectedCondition)
                          .getDisplayName(false),
                    ),
                  ],
                ),

                if (_selectedImages.isNotEmpty) ...[
                  AppSpacing.vertical(UIConstants.spacingL),

                  // Images
                  _buildReviewSection(
                    l10n.donationImages,
                    [
                      Text(
                        '${_selectedImages.length} ${l10n.images}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
        ),
        AppSpacing.vertical(UIConstants.spacingM),
        ...children,
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: UIConstants.spacingS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          ),
          AppSpacing.horizontal(UIConstants.spacingM),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(UIConstants.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: GBSecondaryButton(
                text: l10n.previous,
                onPressed: _previousStep,
              ),
            ),
          if (_currentStep > 0) AppSpacing.horizontal(UIConstants.spacingM),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: GBPrimaryButton(
              text: _currentStep == 3
                  ? (widget.donation != null
                      ? l10n.updateDonation
                      : l10n.createDonation)
                  : l10n.next,
              onPressed: _isLoading
                  ? null
                  : (_currentStep == 3 ? _submitDonation : _nextStep),
              isLoading: _isLoading && _currentStep == 3,
              leftIcon: Icon(
                _currentStep == 3
                    ? (widget.donation != null ? Icons.update : Icons.add)
                    : Icons.arrow_forward,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
