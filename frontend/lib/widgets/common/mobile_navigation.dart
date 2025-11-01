import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/design_system.dart';
import '../../core/utils/responsive_utils.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../language_selector.dart';

/// Mobile-optimized navigation components
class MobileBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<MobileNavItem> items;

  const MobileBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveUtils.isMobile(context)) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        border: Border(
          top: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceS),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignSystem.spaceS,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(DesignSystem.spaceXS),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: DesignSystem.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                                )
                              : null,
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            size: 24,
                            color: isSelected
                                ? DesignSystem.primaryBlue
                                : DesignSystem.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: DesignSystem.labelSmall(context).copyWith(
                            color: isSelected
                                ? DesignSystem.primaryBlue
                                : DesignSystem.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Mobile drawer navigation
class MobileDrawer extends StatelessWidget {
  final List<MobileDrawerItem> items;
  final String? currentRoute;

  const MobileDrawer({
    Key? key,
    required this.items,
    this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Drawer(
      backgroundColor: DesignSystem.getSurfaceColor(context),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(DesignSystem.spaceL),
              decoration: BoxDecoration(
                gradient: DesignSystem.primaryGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: DesignSystem.spaceM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.appTitle,
                              style: DesignSystem.titleMedium(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (user != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                user.name,
                                style: DesignSystem.bodySmall(context).copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceM),
                children: items.map((item) {
                  final isSelected = currentRoute == item.route;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: DesignSystem.spaceM,
                      vertical: DesignSystem.spaceXS,
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DesignSystem.primaryBlue.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected
                              ? DesignSystem.primaryBlue
                              : DesignSystem.textSecondary,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: DesignSystem.bodyMedium(context).copyWith(
                          color: isSelected
                              ? DesignSystem.primaryBlue
                              : DesignSystem.textPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      subtitle: item.subtitle != null
                          ? Text(
                              item.subtitle!,
                              style: DesignSystem.bodySmall(context),
                            )
                          : null,
                      trailing: item.badge != null
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignSystem.spaceS,
                                vertical: DesignSystem.spaceXS,
                              ),
                              decoration: BoxDecoration(
                                color: DesignSystem.error,
                                borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
                              ),
                              child: Text(
                                item.badge!,
                                style: DesignSystem.labelSmall(context).copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: DesignSystem.textTertiary,
                            ),
                      onTap: () {
                        Navigator.pop(context);
                        item.onTap();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                      ),
                      selected: isSelected,
                      selectedTileColor: DesignSystem.primaryBlue.withValues(alpha: 0.05),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Footer actions
            Container(
              padding: const EdgeInsets.all(DesignSystem.spaceL),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: DesignSystem.getBorderColor(context),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Language selector
                  ListTile(
                    leading: const Icon(
                      Icons.language,
                      color: DesignSystem.textSecondary,
                    ),
                    title: Text(
                      l10n.language,
                      style: DesignSystem.bodyMedium(context),
                    ),
                    trailing: const LanguageToggleButton(),
                    onTap: () {
                      Navigator.pop(context);
                      _showLanguageSelector(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.settings_outlined,
                      color: DesignSystem.textSecondary,
                    ),
                    title: Text(
                      l10n.settings,
                      style: DesignSystem.bodyMedium(context),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: DesignSystem.error,
                    ),
                    title: Text(
                      l10n.logout,
                      style: DesignSystem.bodyMedium(context).copyWith(
                        color: DesignSystem.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      authProvider.logout();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(DesignSystem.radiusL)),
      ),
      builder: (context) => const LanguageSelector(showAsButton: false),
    );
  }
}

/// Mobile app bar with responsive design
class MobileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onMenuPressed;
  final Color? backgroundColor;

  const MobileAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onMenuPressed,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? DesignSystem.getSurfaceColor(context),
      elevation: 0,
      centerTitle: true,
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                )
              : (onMenuPressed != null
                  ? IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: onMenuPressed,
                      tooltip: 'Menu',
                    )
                  : null)),
      title: Text(
        title,
        style: DesignSystem.titleMedium(context).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: DesignSystem.getBorderColor(context),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

/// Touch-friendly floating action button
class MobileFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final bool extended;
  final String? label;

  const MobileFAB({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.extended = false,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!ResponsiveUtils.isTouchDevice(context)) {
      return const SizedBox.shrink();
    }

    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        backgroundColor: backgroundColor ?? DesignSystem.primaryBlue,
        foregroundColor: Colors.white,
        tooltip: tooltip,
        elevation: 4,
        highlightElevation: 8,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? DesignSystem.primaryBlue,
      foregroundColor: Colors.white,
      tooltip: tooltip,
      elevation: 4,
      highlightElevation: 8,
      child: Icon(icon, size: 24),
    );
  }
}

/// Data classes for navigation items
class MobileNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const MobileNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class MobileDrawerItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badge;
  final String? route;
  final VoidCallback onTap;

  const MobileDrawerItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badge,
    this.route,
    required this.onTap,
  });
}