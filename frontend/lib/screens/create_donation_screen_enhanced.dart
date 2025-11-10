import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../core/constants/donation_constants.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_multiple_image_upload.dart';
import '../widgets/common/web_card.dart';
import '../widgets/common/gb_text_field.dart';
import '../widgets/rtl/directional_row.dart';
import '../widgets/rtl/directional_column.dart';
import '../widgets/rtl/directional_app_bar.dart';
import '../providers/donation_provider.dart';
import '../providers/locale_provider.dart';
import '../models/donation.dart';
import '../l10n/app_localizations.dart';

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
  String _selectedCategory = DonationCategory.values.first.value;
  String _selectedCondition = DonationCondition.values.first.value;
  List<XFile> _selectedImages = [];

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

      // Get the first image path if available
      String? imagePath;
      String imageUrl = '';
      if (_selectedImages.isNotEmpty) {
        imagePath = _selectedImages.first.path;
        imageUrl = imagePath;
      }

      bool success;
      if (widget.donation != null) {
        success = await donationProvider.updateDonation(
          id: widget.donation!.id.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          condition: _selectedCondition,
          location: _locationController.text.trim(),
          imageUrl: imageUrl,
          imagePath: imagePath,
          isAvailable: true,
        );
      } else {
        success = await donationProvider.createDonation(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          condition: _selectedCondition,
          location: _locationController.text.trim(),
          imageUrl: imageUrl,
          imagePath: imagePath,
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
        content: DirectionalRow(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: DesignSystem.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: DirectionalRow(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: DesignSystem.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  IconData _getCategoryIcon(DonationCategory category) {
    switch (category) {
      case DonationCategory.medical:
        return Icons.medical_services;
      case DonationCategory.education:
        return Icons.school;
      case DonationCategory.food:
        return Icons.restaurant;
      case DonationCategory.housing:
        return Icons.home;
      case DonationCategory.emergency:
        return Icons.emergency;
      case DonationCategory.clothes:
        return Icons.checkroom;
      case DonationCategory.books:
        return Icons.menu_book;
      case DonationCategory.electronics:
        return Icons.devices;
      case DonationCategory.furniture:
        return Icons.chair;
      case DonationCategory.toys:
        return Icons.toys;
      case DonationCategory.other:
        return Icons.category;
    }
  }

  String _getCategoryLocalizedName(
      DonationCategory category, AppLocalizations l10n) {
    switch (category) {
      case DonationCategory.food:
        return l10n.food;
      case DonationCategory.clothes:
        return l10n.clothes;
      case DonationCategory.books:
        return l10n.books;
      case DonationCategory.electronics:
        return l10n.electronics;
      case DonationCategory.furniture:
        return l10n.furniture;
      case DonationCategory.toys:
        return l10n.toys;
      case DonationCategory.other:
        return l10n.other;
      case DonationCategory.medical:
        return 'Medical';
      case DonationCategory.education:
        return 'Education';
      case DonationCategory.housing:
        return 'Housing';
      case DonationCategory.emergency:
        return 'Emergency';
    }
  }

  String _getConditionLocalizedName(DonationCondition condition) {
    switch (condition) {
      case DonationCondition.newCondition:
        return 'New';
      case DonationCondition.likeNew:
        return 'Like New';
      case DonationCondition.good:
        return 'Good';
      case DonationCondition.fair:
        return 'Fair';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: localeProvider.textDirection,
      child: Scaffold(
        backgroundColor: DesignSystem.getBackgroundColor(context),
        appBar: DirectionalAppBar(
          backgroundColor: DesignSystem.getSurfaceColor(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              localeProvider.getDirectionalIcon(
                start: Icons.arrow_back,
                end: Icons.arrow_forward,
              ),
              color: isDark ? DesignSystem.neutral200 : DesignSystem.neutral900,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.donation != null ? l10n.editDonation : l10n.createDonation,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark
                      ? DesignSystem.neutral200
                      : DesignSystem.neutral900,
                  fontWeight: FontWeight.w600,
                ),
          ),
          centerTitle: localeProvider.isRTL,
          actions: [
            if (_currentStep > 0)
              TextButton(
                onPressed: _previousStep,
                child: Text(
                  l10n.previous,
                  style: TextStyle(color: DesignSystem.primaryBlue),
                ),
              ),
          ],
        ),
        body: DirectionalColumn(
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
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
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
                              ? DesignSystem.primaryBlue
                              : (isDark
                                  ? DesignSystem.neutral700
                                  : DesignSystem.neutral300),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < 3) const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'Step ${_currentStep + 1} of 4',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: DesignSystem.neutral600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            WebCard(
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: DesignSystem.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: DesignSystem.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
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
                        const SizedBox(width: 8),
                        Text(
                          l10n.basicInfoDescription,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: DesignSystem.neutral600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Form Fields
            WebCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  GBTextField(
                    label: l10n.donationTitle,
                    hint: l10n.donationTitleHint,
                    controller: _titleController,
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

                  const SizedBox(height: 16),

                  // Description
                  GBTextField(
                    label: l10n.donationDescription,
                    hint: l10n.donationDescriptionHint,
                    controller: _descriptionController,
                    maxLines: 4,
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

                  const SizedBox(height: 16),

                  // Location
                  GBTextField(
                    label: l10n.donationLocation,
                    hint: l10n.donationLocationHint,
                    controller: _locationController,
                    prefixIcon: Icon(Icons.location_on_outlined),
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

                  const SizedBox(height: 16),

                  // Quantity
                  GBTextField(
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

                  const SizedBox(height: 16),

                  // Notes
                  GBTextField(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          WebCard(
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    color: DesignSystem.primaryBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 8),
                      Text(
                        l10n.categoryDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: DesignSystem.neutral600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Category Selection
          WebCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.donationCategory,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DesignSystem.primaryBlue
                              : (isDark
                                  ? DesignSystem.neutral800
                                  : DesignSystem.neutral100),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? DesignSystem.primaryBlue
                                : (isDark
                                    ? DesignSystem.neutral700
                                    : DesignSystem.neutral300),
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
                                  : DesignSystem.neutral600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getCategoryLocalizedName(category, l10n),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? DesignSystem.neutral200
                                            : DesignSystem.neutral900),
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

          const SizedBox(height: 24),

          // Condition Selection
          WebCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.condition,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
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
                          margin: const EdgeInsets.only(
                            right: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(DonationConstants
                                    .conditionColors[condition.value]!)
                                : (isDark
                                    ? DesignSystem.neutral800
                                    : DesignSystem.neutral100),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Color(DonationConstants
                                      .conditionColors[condition.value]!)
                                  : (isDark
                                      ? DesignSystem.neutral700
                                      : DesignSystem.neutral300),
                            ),
                          ),
                          child: Text(
                            _getConditionLocalizedName(condition),
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                              ? DesignSystem.neutral200
                                              : DesignSystem.neutral900),
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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Multiple Image Upload Component
          GBMultipleImageUpload(
            label: l10n.donationImages,
            helperText: l10n.imagesDescription,
            maxImages: 6,
            maxSizeMB: 5.0,
            initialImages: _selectedImages,
            onImagesChanged: (images) {
              setState(() {
                _selectedImages = images;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          WebCard(
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: DesignSystem.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: DesignSystem.success,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 8),
                      Text(
                        l10n.reviewDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: DesignSystem.neutral600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Review Content
          WebCard(
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

                const SizedBox(height: 24),

                // Category and Condition
                _buildReviewSection(
                  l10n.categoryAndCondition,
                  [
                    _buildReviewItem(
                      l10n.donationCategory,
                      _getCategoryLocalizedName(
                        DonationCategory.fromString(_selectedCategory),
                        l10n,
                      ),
                    ),
                    _buildReviewItem(
                      l10n.condition,
                      _getConditionLocalizedName(
                        DonationCondition.fromString(_selectedCondition),
                      ),
                    ),
                  ],
                ),

                if (_selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 24),

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
                color: DesignSystem.primaryBlue,
              ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignSystem.neutral600,
                  ),
            ),
          ),
          const SizedBox(width: 16),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
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
              child: GBButton(
                text: l10n.previous,
                variant: GBButtonVariant.secondary,
                onPressed: _previousStep,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: GBButton(
              text: _currentStep == 3
                  ? (widget.donation != null
                      ? l10n.updateDonation
                      : l10n.createDonation)
                  : l10n.next,
              variant: GBButtonVariant.primary,
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
