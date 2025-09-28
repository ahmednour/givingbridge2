import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
import '../services/api_service.dart';
import '../models/donation.dart';

class CreateDonationScreen extends StatefulWidget {
  final Donation? donation;
  const CreateDonationScreen({Key? key, this.donation}) : super(key: key);

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = 'food';
  String _selectedCondition = 'good';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {'value': 'food', 'label': 'Food', 'icon': Icons.restaurant},
    {'value': 'clothes', 'label': 'Clothes', 'icon': Icons.checkroom},
    {'value': 'books', 'label': 'Books', 'icon': Icons.menu_book},
    {'value': 'electronics', 'label': 'Electronics', 'icon': Icons.devices},
    {'value': 'other', 'label': 'Other', 'icon': Icons.category},
  ];

  final List<Map<String, dynamic>> _conditions = [
    {'value': 'new', 'label': 'New', 'color': Colors.green},
    {'value': 'like-new', 'label': 'Like New', 'color': Colors.lightGreen},
    {'value': 'good', 'label': 'Good', 'color': Colors.orange},
    {'value': 'fair', 'label': 'Fair', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.donation != null) {
      _populateFormFields();
    }
  }

  void _populateFormFields() {
    final donation = widget.donation!;
    _titleController.text = donation.title;
    _descriptionController.text = donation.description;
    _locationController.text = donation.location;
    _selectedCategory = donation.category;
    _selectedCondition = donation.condition;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = widget.donation != null
          ? await ApiService.updateDonation(
              id: widget.donation!.id.toString(),
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              category: _selectedCategory,
              condition: _selectedCondition,
              location: _locationController.text.trim(),
            )
          : await ApiService.createDonation(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              category: _selectedCategory,
              condition: _selectedCondition,
              location: _locationController.text.trim(),
            );

      if (response.success) {
        _showSuccessSnackbar(widget.donation != null
            ? 'Donation updated successfully!'
            : 'Donation created successfully!');
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        _showErrorSnackbar(response.error ?? 'An error occurred');
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
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.donation != null ? 'Edit Donation' : 'Create Donation',
          style: const TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: AppTheme.shadowMD,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: const Icon(
                          Icons.volunteer_activism,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.donation != null
                                  ? 'Update Your Donation'
                                  : 'Share Your Kindness',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimaryColor,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingXS),
                            Text(
                              'Help someone in need by donating items you no longer use',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Form Fields Card
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: AppTheme.shadowMD,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Donation Details',
                        style: AppTheme.headingSmall,
                      ),
                      const SizedBox(height: AppTheme.spacingL),

                      // Title
                      AppInput(
                        controller: _titleController,
                        label: 'Title *',
                        hint: 'e.g., Winter Clothes for Children',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          if (value.trim().length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingM),

                      // Description
                      AppInput(
                        controller: _descriptionController,
                        label: 'Description *',
                        hint: 'Describe the items you\'re donating...',
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          if (value.trim().length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingM),

                      // Category Selection
                      Text(
                        'Category *',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Wrap(
                        spacing: AppTheme.spacingS,
                        runSpacing: AppTheme.spacingS,
                        children: _categories.map((category) {
                          final isSelected =
                              _selectedCategory == category['value'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category['value'];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                                vertical: AppTheme.spacingS,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.surfaceColor,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusM),
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
                                    category['icon'],
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textSecondaryColor,
                                  ),
                                  const SizedBox(width: AppTheme.spacingXS),
                                  Text(
                                    category['label'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: AppTheme.spacingM),

                      // Condition Selection
                      Text(
                        'Condition *',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Row(
                        children: _conditions.map((condition) {
                          final isSelected =
                              _selectedCondition == condition['value'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCondition = condition['value'];
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                    right: AppTheme.spacingXS),
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppTheme.spacingS,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? condition['color']
                                      : AppTheme.surfaceColor,
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusM),
                                  border: Border.all(
                                    color: isSelected
                                        ? condition['color']
                                        : AppTheme.borderColor,
                                  ),
                                ),
                                child: Text(
                                  condition['label'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textPrimaryColor,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: AppTheme.spacingM),

                      // Location
                      AppInput(
                        controller: _locationController,
                        label: 'Location *',
                        hint: 'Enter pickup location',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a location';
                          }
                          if (value.trim().length < 2) {
                            return 'Location must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingL),

                // Submit Button
                AppButton(
                  text: widget.donation != null
                      ? 'Update Donation'
                      : 'Create Donation',
                  onPressed: _isLoading ? null : _submitForm,
                  isLoading: _isLoading,
                  size: ButtonSize.large,
                  width: double.infinity,
                ),

                const SizedBox(height: AppTheme.spacingM),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
