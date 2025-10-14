import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/constants/donation_constants.dart';
import '../../core/theme/app_theme_enhanced.dart';
import '../../core/utils/rtl_utils.dart';
import '../../widgets/app_components.dart';
import '../../providers/filter_provider.dart';
import '../../models/donation.dart';
import '../../l10n/app_localizations.dart';

/// Enhanced donation card with better design and RTL support
class EnhancedDonationCard extends StatelessWidget {
  final Donation donation;
  final VoidCallback? onTap;
  final VoidCallback? onRequest;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EnhancedDonationCard({
    Key? key,
    required this.donation,
    this.onTap,
    this.onRequest,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLUtils.isRTL(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment:
            isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Image and status
          Stack(
            children: [
              Container(
                height: UIConstants.donationCardHeight * 0.6,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  color: AppTheme.backgroundColor,
                ),
                child: donation.imageUrl != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusM),
                        child: Image.network(
                          donation.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        ),
                      )
                    : _buildPlaceholderImage(),
              ),
              Positioned(
                top: UIConstants.spacingS,
                right: isRTL ? null : UIConstants.spacingS,
                left: isRTL ? UIConstants.spacingS : null,
                child: _buildStatusChip(context, donation.status),
              ),
            ],
          ),
          AppSpacing.vertical(UIConstants.spacingM),

          // Title and description
          Text(
            donation.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.vertical(UIConstants.spacingS),
          Text(
            donation.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.vertical(UIConstants.spacingM),

          // Category and condition
          Row(
            children: [
              _buildInfoChip(
                context,
                DonationCategory.fromString(donation.category)
                    .getDisplayName(isRTL),
                Icons.category,
                AppTheme.primaryColor,
              ),
              AppSpacing.horizontal(UIConstants.spacingS),
              _buildInfoChip(
                context,
                DonationCondition.fromString(donation.condition)
                    .getDisplayName(isRTL),
                Icons.star,
                AppTheme.accentColor,
              ),
            ],
          ),
          AppSpacing.vertical(UIConstants.spacingM),

          // Location and donor
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: UIConstants.iconS,
                color: AppTheme.textSecondaryColor,
              ),
              AppSpacing.horizontal(UIConstants.spacingXS),
              Expanded(
                child: Text(
                  donation.location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.vertical(UIConstants.spacingS),
          Row(
            children: [
              Icon(
                Icons.person,
                size: UIConstants.iconS,
                color: AppTheme.textSecondaryColor,
              ),
              AppSpacing.horizontal(UIConstants.spacingXS),
              Expanded(
                child: Text(
                  donation.donorName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          AppSpacing.vertical(UIConstants.spacingM),

          // Action buttons
          Row(
            children: [
              if (onRequest != null && donation.isAvailable) ...[
                Expanded(
                  child: AppButton(
                    text: l10n.request,
                    type: AppButtonType.primary,
                    size: AppButtonSize.small,
                    onPressed: onRequest,
                  ),
                ),
                AppSpacing.horizontal(UIConstants.spacingS),
              ],
              if (onEdit != null) ...[
                AppButton(
                  text: l10n.edit,
                  type: AppButtonType.secondary,
                  size: AppButtonSize.small,
                  onPressed: onEdit,
                ),
                AppSpacing.horizontal(UIConstants.spacingS),
              ],
              if (onDelete != null) ...[
                AppButton(
                  text: l10n.delete,
                  type: AppButtonType.text,
                  size: AppButtonSize.small,
                  textColor: AppTheme.errorColor,
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        color: AppTheme.backgroundColor,
      ),
      child: Center(
        child: Icon(
          Icons.image,
          size: UIConstants.iconXL,
          color: AppTheme.textHintColor,
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final statusInfo = DonationStatus.fromString(status);
    final color =
        DonationConstants.statusColors[status] ?? AppTheme.primaryColor;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UIConstants.spacingS,
        vertical: UIConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: (color as Color).withOpacity( 0.9),
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
      ),
      child: Text(
        statusInfo.getDisplayName(RTLUtils.isRTL(context)),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildInfoChip(
      BuildContext context, String text, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: UIConstants.spacingS,
        vertical: UIConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(UIConstants.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: UIConstants.iconXS,
            color: color,
          ),
          AppSpacing.horizontal(UIConstants.spacingXS),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

/// Advanced filter widget for donations
class DonationFilterWidget extends StatefulWidget {
  final VoidCallback? onFilterChanged;
  final VoidCallback? onClearFilters;

  const DonationFilterWidget({
    Key? key,
    this.onFilterChanged,
    this.onClearFilters,
  }) : super(key: key);

  @override
  State<DonationFilterWidget> createState() => _DonationFilterWidgetState();
}

class _DonationFilterWidgetState extends State<DonationFilterWidget> {
  String? _selectedCategory;
  String? _selectedCondition;
  String? _selectedStatus;
  bool? _availableOnly;

  @override
  Widget build(BuildContext context) {
    final isRTL = RTLUtils.isRTL(context);
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Column(
        crossAxisAlignment:
            isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.filter,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () {
                  _clearFilters();
                  widget.onClearFilters?.call();
                },
                child: Text('مسح الفلاتر'),
              ),
            ],
          ),
          AppSpacing.vertical(UIConstants.spacingL),

          // Category filter
          Text(
            l10n.category,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          AppSpacing.vertical(UIConstants.spacingS),
          Wrap(
            spacing: UIConstants.spacingS,
            children: [
              _buildFilterChip('all', 'الكل', _selectedCategory == null),
              ...DonationCategory.values.map((category) {
                return _buildFilterChip(
                  category.value,
                  category.getDisplayName(isRTL),
                  _selectedCategory == category.value,
                );
              }),
            ],
          ),
          AppSpacing.vertical(UIConstants.spacingL),

          // Condition filter
          Text(
            l10n.condition,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          AppSpacing.vertical(UIConstants.spacingS),
          Wrap(
            spacing: UIConstants.spacingS,
            children: [
              _buildFilterChip('all', 'الكل', _selectedCondition == null),
              ...DonationCondition.values.map((condition) {
                return _buildFilterChip(
                  condition.value,
                  condition.getDisplayName(isRTL),
                  _selectedCondition == condition.value,
                );
              }),
            ],
          ),
          AppSpacing.vertical(UIConstants.spacingL),

          // Status filter
          Text(
            l10n.request,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          AppSpacing.vertical(UIConstants.spacingS),
          Wrap(
            spacing: UIConstants.spacingS,
            children: [
              _buildFilterChip('all', 'الكل', _selectedStatus == null),
              ...DonationStatus.values.map((status) {
                return _buildFilterChip(
                  status.value,
                  status.getDisplayName(isRTL),
                  _selectedStatus == status.value,
                );
              }),
            ],
          ),
          AppSpacing.vertical(UIConstants.spacingL),

          // Available only toggle
          Row(
            children: [
              Checkbox(
                value: _availableOnly ?? false,
                onChanged: (value) {
                  setState(() {
                    _availableOnly = value;
                  });
                  _applyFilters();
                },
              ),
              Expanded(
                child: Text(
                  'المتاح فقط',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          AppSpacing.vertical(UIConstants.spacingL),

          // Apply filters button
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'تطبيق الفلاتر',
              type: AppButtonType.primary,
              onPressed: () {
                _applyFilters();
                widget.onFilterChanged?.call();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (value == 'all') {
            if (label == 'الكل') {
              _selectedCategory = null;
              _selectedCondition = null;
              _selectedStatus = null;
            }
          } else {
            if (label ==
                DonationCategory.fromString(value)
                    .getDisplayName(RTLUtils.isRTL(context))) {
              _selectedCategory = selected ? value : null;
            } else if (label ==
                DonationCondition.fromString(value)
                    .getDisplayName(RTLUtils.isRTL(context))) {
              _selectedCondition = selected ? value : null;
            } else if (label ==
                DonationStatus.fromString(value)
                    .getDisplayName(RTLUtils.isRTL(context))) {
              _selectedStatus = selected ? value : null;
            }
          }
        });
      },
      selectedColor: AppTheme.primaryColor.withOpacity( 0.2),
      checkmarkColor: AppTheme.primaryColor,
    );
  }

  void _applyFilters() {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    filterProvider.setCategory(_selectedCategory);
    filterProvider.setCondition(_selectedCondition);
    filterProvider.setStatus(_selectedStatus);
    filterProvider.setAvailable(_availableOnly);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedCondition = null;
      _selectedStatus = null;
      _availableOnly = null;
    });
  }
}

/// Search bar widget for donations
class DonationSearchBar extends StatefulWidget {
  final String? initialQuery;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchSubmitted;

  const DonationSearchBar({
    Key? key,
    this.initialQuery,
    this.onSearchChanged,
    this.onSearchSubmitted,
  }) : super(key: key);

  @override
  State<DonationSearchBar> createState() => _DonationSearchBarState();
}

class _DonationSearchBarState extends State<DonationSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: _controller,
              hint: l10n.search,
              prefixIcon: Icon(
                Icons.search,
                color: AppTheme.textSecondaryColor,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _controller.clear();
                        widget.onSearchChanged?.call('');
                        setState(() {});
                      },
                      icon: Icon(
                        Icons.clear,
                        color: AppTheme.textSecondaryColor,
                      ),
                    )
                  : null,
              onChanged: (value) {
                setState(() {});
                widget.onSearchChanged?.call(value);
              },
              onSubmitted: (value) {
                widget.onSearchSubmitted?.call();
              },
            ),
          ),
          AppSpacing.horizontal(UIConstants.spacingM),
          AppButton(
            text: l10n.filter,
            type: AppButtonType.secondary,
            icon: Icons.filter_list,
            onPressed: () {
              // Show filter bottom sheet
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(UIConstants.radiusL),
          ),
        ),
        child: const DonationFilterWidget(),
      ),
    );
  }
}
