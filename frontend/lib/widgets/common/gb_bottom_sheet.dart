import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import 'gb_button.dart';

/// Enhanced Bottom Sheet Modal for GivingBridge
/// Mobile-friendly alternative to dialogs
class GBBottomSheet {
  /// Show a simple bottom sheet with title and content
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool isDismissible = true,
    bool showDragHandle = true,
    double initialChildSize = 0.6,
    double maxChildSize = 0.9,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        minChildSize: 0.4,
        maxChildSize: maxChildSize,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: DesignSystem.getSurfaceColor(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignSystem.radiusXXL),
            ),
            boxShadow: DesignSystem.elevation4,
          ),
          child: Column(
            children: [
              // Drag handle
              if (showDragHandle)
                Container(
                  margin: const EdgeInsets.only(
                    top: DesignSystem.spaceM,
                    bottom: DesignSystem.spaceS,
                  ),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DesignSystem.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignSystem.spaceXL,
                  DesignSystem.spaceL,
                  DesignSystem.spaceXL,
                  DesignSystem.spaceM,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: DesignSystem.headlineSmall(context),
                      ),
                    ),
                    if (isDismissible)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        constraints: const BoxConstraints(
                          minWidth: DesignSystem.minTouchTarget,
                          minHeight: DesignSystem.minTouchTarget,
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(DesignSystem.spaceXL),
                  child: content,
                ),
              ),

              // Actions
              if (actions != null && actions.isNotEmpty) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(DesignSystem.spaceL),
                  child: Row(
                    children: actions,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Show confirmation bottom sheet
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    GBButtonVariant confirmVariant = GBButtonVariant.primary,
    IconData? icon,
    Color? iconColor,
  }) {
    return show<bool>(
      context: context,
      title: title,
      initialChildSize: 0.4,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (iconColor ?? DesignSystem.primaryBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor ?? DesignSystem.primaryBlue,
              ),
            ),
            const SizedBox(height: DesignSystem.spaceL),
          ],
          Text(
            message,
            style: DesignSystem.bodyLarge(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Expanded(
          child: GBOutlineButton(
            text: cancelLabel,
            onPressed: () => Navigator.pop(context, false),
            fullWidth: true,
          ),
        ),
        const SizedBox(width: DesignSystem.spaceM),
        Expanded(
          child: GBButton(
            text: confirmLabel,
            variant: confirmVariant,
            onPressed: () => Navigator.pop(context, true),
            fullWidth: true,
          ),
        ),
      ],
    );
  }

  /// Show delete confirmation
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String itemName,
    String? message,
  }) {
    return showConfirmation(
      context: context,
      title: 'Delete $itemName?',
      message: message ?? 'This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      confirmVariant: GBButtonVariant.danger,
      icon: Icons.delete_outline,
      iconColor: DesignSystem.error,
    );
  }

  /// Show list selection bottom sheet
  static Future<T?> showListSelection<T>({
    required BuildContext context,
    required String title,
    required List<GBListItem<T>> items,
    T? selectedValue,
  }) {
    return show<T>(
      context: context,
      title: title,
      initialChildSize: 0.5,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.map((item) {
          final isSelected = selectedValue == item.value;
          return ListTile(
            leading: item.icon != null
                ? Icon(
                    item.icon,
                    color: isSelected
                        ? DesignSystem.primaryBlue
                        : DesignSystem.textSecondary,
                  )
                : null,
            title: Text(
              item.label,
              style: DesignSystem.bodyLarge(context).copyWith(
                color: isSelected
                    ? DesignSystem.primaryBlue
                    : DesignSystem.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
            trailing: isSelected
                ? const Icon(Icons.check, color: DesignSystem.primaryBlue)
                : null,
            selected: isSelected,
            selectedTileColor: DesignSystem.primaryBlue.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            onTap: () => Navigator.pop(context, item.value),
          );
        }).toList(),
      ),
    );
  }

  /// Show loading bottom sheet
  static void showLoading(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    show(
      context: context,
      title: '',
      isDismissible: false,
      showDragHandle: false,
      initialChildSize: 0.3,
      content: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: DesignSystem.spaceL),
            Text(
              message,
              style: DesignSystem.bodyLarge(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// List item for selection bottom sheets
class GBListItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const GBListItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });
}

/// Usage Examples:
/// 
/// // Simple bottom sheet
/// GBBottomSheet.show(
///   context: context,
///   title: 'Filter Options',
///   content: FilterForm(),
///   actions: [
///     GBOutlineButton(text: 'Reset', onPressed: _reset),
///     GBPrimaryButton(text: 'Apply', onPressed: _apply),
///   ],
/// );
/// 
/// // Confirmation
/// final confirmed = await GBBottomSheet.showConfirmation(
///   context: context,
///   title: 'Confirm Action',
///   message: 'Are you sure you want to proceed?',
/// );
/// 
/// // Delete confirmation
/// final delete = await GBBottomSheet.showDeleteConfirmation(
///   context: context,
///   itemName: 'Donation',
/// );
/// 
/// // List selection
/// final category = await GBBottomSheet.showListSelection<String>(
///   context: context,
///   title: 'Select Category',
///   items: [
///     GBListItem(value: 'food', label: 'Food', icon: Icons.restaurant),
///     GBListItem(value: 'clothes', label: 'Clothes', icon: Icons.checkroom),
///   ],
///   selectedValue: currentCategory,
/// );
