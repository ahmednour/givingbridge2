import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_system.dart';
import '../../providers/theme_provider.dart';

/// Theme Toggle Widget for switching between light/dark modes
///
/// Features:
/// - Icon button variant
/// - Switch variant
/// - Segmented control variant
/// - Smooth animations
///
/// Usage:
/// ```dart
/// GBThemeToggle.iconButton()
/// GBThemeToggle.switchToggle()
/// GBThemeToggle.segmented()
/// ```
class GBThemeToggle extends StatelessWidget {
  final GBThemeToggleVariant variant;
  final bool showLabel;
  final String? label;

  const GBThemeToggle({
    Key? key,
    this.variant = GBThemeToggleVariant.iconButton,
    this.showLabel = false,
    this.label,
  }) : super(key: key);

  /// Icon button variant (compact, single tap to toggle)
  factory GBThemeToggle.iconButton({bool showLabel = false}) {
    return GBThemeToggle(
      variant: GBThemeToggleVariant.iconButton,
      showLabel: showLabel,
    );
  }

  /// Switch toggle variant (iOS-style switch)
  factory GBThemeToggle.switchToggle({String? label}) {
    return GBThemeToggle(
      variant: GBThemeToggleVariant.switchToggle,
      showLabel: true,
      label: label,
    );
  }

  /// Segmented control variant (light/dark/system buttons)
  factory GBThemeToggle.segmented() {
    return const GBThemeToggle(
      variant: GBThemeToggleVariant.segmented,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    switch (variant) {
      case GBThemeToggleVariant.iconButton:
        return _buildIconButton(context, themeProvider);
      case GBThemeToggleVariant.switchToggle:
        return _buildSwitchToggle(context, themeProvider);
      case GBThemeToggleVariant.segmented:
        return _buildSegmentedControl(context, themeProvider);
    }
  }

  Widget _buildIconButton(BuildContext context, ThemeProvider themeProvider) {
    final isDark = themeProvider.shouldUseDarkMode(context);

    return IconButton(
      icon: AnimatedSwitcher(
        duration: DesignSystem.shortDuration,
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
          color: isDark ? DesignSystem.warning : DesignSystem.accentAmber,
        ),
      ),
      onPressed: () => themeProvider.toggleTheme(),
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }

  Widget _buildSwitchToggle(BuildContext context, ThemeProvider themeProvider) {
    final isDark = themeProvider.shouldUseDarkMode(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.light_mode,
          size: 20,
          color: isDark ? DesignSystem.textSecondary : DesignSystem.accentAmber,
        ),
        const SizedBox(width: DesignSystem.spaceS),
        Switch(
          value: isDark,
          onChanged: (_) => themeProvider.toggleTheme(),
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return DesignSystem.primaryBlue;
            }
            return DesignSystem.neutral400;
          }),
        ),
        const SizedBox(width: DesignSystem.spaceS),
        Icon(
          Icons.dark_mode,
          size: 20,
          color: isDark ? DesignSystem.accentAmber : DesignSystem.textSecondary,
        ),
        if (showLabel && label != null) ...[
          const SizedBox(width: DesignSystem.spaceM),
          Text(
            label!,
            style: DesignSystem.bodyMedium(context),
          ),
        ],
      ],
    );
  }

  Widget _buildSegmentedControl(
      BuildContext context, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(
          color: DesignSystem.getBorderColor(context),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegmentButton(
            context,
            themeProvider,
            ThemeMode.light,
            Icons.light_mode,
            'Light',
          ),
          const SizedBox(width: 4),
          _buildSegmentButton(
            context,
            themeProvider,
            ThemeMode.dark,
            Icons.dark_mode,
            'Dark',
          ),
          const SizedBox(width: 4),
          _buildSegmentButton(
            context,
            themeProvider,
            ThemeMode.system,
            Icons.brightness_auto,
            'Auto',
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton(
    BuildContext context,
    ThemeProvider themeProvider,
    ThemeMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = themeProvider.themeMode == mode;

    return InkWell(
      onTap: () => themeProvider.setThemeMode(mode),
      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      child: AnimatedContainer(
        duration: DesignSystem.shortDuration,
        curve: DesignSystem.defaultCurve,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignSystem.radiusS),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? DesignSystem.primaryBlue
                  : DesignSystem.textSecondary,
            ),
            const SizedBox(width: DesignSystem.spaceXS),
            Text(
              label,
              style: DesignSystem.labelMedium(context).copyWith(
                color: isSelected
                    ? DesignSystem.primaryBlue
                    : DesignSystem.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Theme toggle variants
enum GBThemeToggleVariant {
  iconButton,
  switchToggle,
  segmented,
}
