import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import '../../l10n/app_localizations.dart';

/// Filter Chips Component for GivingBridge
/// Multi-select or single-select filtering with chips
class GBFilterChips<T> extends StatefulWidget {
  final List<GBFilterOption<T>> options;
  final List<T> selectedValues;
  final Function(List<T>) onChanged;
  final bool multiSelect;
  final String? label;
  final bool scrollable;

  const GBFilterChips({
    Key? key,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    this.multiSelect = true,
    this.label,
    this.scrollable = true,
  }) : super(key: key);

  @override
  State<GBFilterChips<T>> createState() => _GBFilterChipsState<T>();
}

class _GBFilterChipsState<T> extends State<GBFilterChips<T>> {
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedValues);
  }

  void _toggleSelection(T value) {
    setState(() {
      if (widget.multiSelect) {
        if (_selected.contains(value)) {
          _selected.remove(value);
        } else {
          _selected.add(value);
        }
      } else {
        _selected = [value];
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: DesignSystem.labelLarge(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_selected.isNotEmpty) ...[
                const SizedBox(width: DesignSystem.spaceS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSystem.spaceS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryBlue,
                    borderRadius:
                        BorderRadius.circular(DesignSystem.radiusPill),
                  ),
                  child: Text(
                    _selected.length.toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (_selected.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() => _selected.clear());
                    widget.onChanged(_selected);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: DesignSystem.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: DesignSystem.spaceM),
                  ),
                  child: Text(AppLocalizations.of(context)!.clear),
                ),
            ],
          ),
          const SizedBox(height: DesignSystem.spaceM),
        ],
        widget.scrollable
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildChips(),
              )
            : Wrap(
                spacing: DesignSystem.spaceS,
                runSpacing: DesignSystem.spaceS,
                children:
                    widget.options.map((option) => _buildChip(option)).toList(),
              ),
      ],
    );
  }

  Widget _buildChips() {
    return Row(
      children: widget.options.map((option) {
        final isLast = widget.options.last == option;
        return Padding(
          padding: EdgeInsets.only(right: isLast ? 0 : DesignSystem.spaceS),
          child: _buildChip(option),
        );
      }).toList(),
    );
  }

  Widget _buildChip(GBFilterOption<T> option) {
    final isSelected = _selected.contains(option.value);
    final color = option.color ?? DesignSystem.primaryBlue;

    return AnimatedContainer(
      duration: DesignSystem.shortDuration,
      curve: DesignSystem.defaultCurve,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleSelection(option.value),
          borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceL,
              vertical: DesignSystem.spaceM,
            ),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
              border: Border.all(
                color:
                    isSelected ? color : DesignSystem.getBorderColor(context),
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Icon(
                    option.icon,
                    size: DesignSystem.iconSizeSmall,
                    color:
                        isSelected ? Colors.white : DesignSystem.textSecondary,
                  ),
                  const SizedBox(width: DesignSystem.spaceS),
                ],
                Text(
                  option.label,
                  style: DesignSystem.labelLarge(context).copyWith(
                    color: isSelected ? Colors.white : DesignSystem.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (option.count != null) ...[
                  const SizedBox(width: DesignSystem.spaceS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignSystem.spaceS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.3)
                          : DesignSystem.neutral200,
                      borderRadius:
                          BorderRadius.circular(DesignSystem.radiusPill),
                    ),
                    child: Text(
                      option.count.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : DesignSystem.textSecondary,
                      ),
                    ),
                  ),
                ],
                if (isSelected) ...[
                  const SizedBox(width: DesignSystem.spaceS),
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Filter option model
class GBFilterOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? color;
  final int? count;

  const GBFilterOption({
    required this.value,
    required this.label,
    this.icon,
    this.color,
    this.count,
  });
}

/// Preset category filters
class GBCategoryFilters extends StatelessWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onChanged;

  const GBCategoryFilters({
    Key? key,
    required this.selectedCategories,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GBFilterChips<String>(
      label: 'Categories',
      options: const [
        GBFilterOption(
          value: 'food',
          label: 'Food',
          icon: Icons.restaurant,
          color: DesignSystem.success,
        ),
        GBFilterOption(
          value: 'clothes',
          label: 'Clothes',
          icon: Icons.checkroom,
          color: DesignSystem.accentPink,
        ),
        GBFilterOption(
          value: 'books',
          label: 'Books',
          icon: Icons.menu_book,
          color: DesignSystem.accentPurple,
        ),
        GBFilterOption(
          value: 'electronics',
          label: 'Electronics',
          icon: Icons.devices,
          color: DesignSystem.info,
        ),
        GBFilterOption(
          value: 'other',
          label: 'Other',
          icon: Icons.category,
          color: DesignSystem.neutral500,
        ),
      ],
      selectedValues: selectedCategories,
      onChanged: onChanged,
    );
  }
}

/// Preset status filters
class GBStatusFilters extends StatelessWidget {
  final List<String> selectedStatuses;
  final Function(List<String>) onChanged;

  const GBStatusFilters({
    Key? key,
    required this.selectedStatuses,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GBFilterChips<String>(
      label: 'Status',
      options: const [
        GBFilterOption(
          value: 'available',
          label: 'Available',
          icon: Icons.check_circle,
          color: DesignSystem.success,
        ),
        GBFilterOption(
          value: 'pending',
          label: 'Pending',
          icon: Icons.hourglass_empty,
          color: DesignSystem.warning,
        ),
        GBFilterOption(
          value: 'completed',
          label: 'Completed',
          icon: Icons.done_all,
          color: DesignSystem.info,
        ),
        GBFilterOption(
          value: 'cancelled',
          label: 'Cancelled',
          icon: Icons.cancel,
          color: DesignSystem.error,
        ),
      ],
      selectedValues: selectedStatuses,
      onChanged: onChanged,
    );
  }
}

/// Usage Examples:
/// 
/// // Basic usage
/// GBFilterChips<String>(
///   label: 'Filter by Category',
///   options: [
///     GBFilterOption(value: 'food', label: 'Food', icon: Icons.restaurant),
///     GBFilterOption(value: 'clothes', label: 'Clothes', count: 12),
///   ],
///   selectedValues: _selectedCategories,
///   onChanged: (values) => setState(() => _selectedCategories = values),
/// )
/// 
/// // Preset category filters
/// GBCategoryFilters(
///   selectedCategories: _categories,
///   onChanged: (values) => _filterByCategories(values),
/// )
/// 
/// // Single select
/// GBFilterChips<String>(
///   multiSelect: false,
///   options: [...],
///   selectedValues: [_selectedValue],
///   onChanged: (values) => setState(() => _selectedValue = values.first),
/// )
