import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';

/// Responsive Navigation System for GivingBridge
/// Displays drawer on mobile, horizontal nav on desktop
class GBNavigation extends StatelessWidget {
  final String title;
  final List<GBNavItem> items;
  final int currentIndex;
  final Function(int) onItemTap;
  final Widget? trailing;
  final String? userName;
  final String? userRole;
  final VoidCallback? onLogout;

  const GBNavigation({
    Key? key,
    required this.title,
    required this.items,
    required this.currentIndex,
    required this.onItemTap,
    this.trailing,
    this.userName,
    this.userRole,
    this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = DesignSystem.isMobile(context);

    if (isMobile) {
      return _buildMobileNavigation(context);
    } else {
      return _buildDesktopNavigation(context);
    }
  }

  Widget _buildDesktopNavigation(BuildContext context) {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.getResponsivePadding(
          MediaQuery.of(context).size.width,
        ),
      ),
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 1,
          ),
        ),
        boxShadow: DesignSystem.elevation1,
      ),
      child: Row(
        children: [
          // Logo + Title
          _buildLogo(context),
          const SizedBox(width: DesignSystem.spaceXL),

          // Navigation Items
          Expanded(
            child: Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: DesignSystem.spaceM),
                  child: _buildNavItem(context, item, index, false),
                );
              }).toList(),
            ),
          ),

          // Trailing widgets (notifications, profile, etc.)
          if (trailing != null) trailing!,

          // User Profile
          if (userName != null) ...[
            const SizedBox(width: DesignSystem.spaceL),
            _buildUserProfile(context),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileNavigation(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: DesignSystem.spaceL),
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Menu Button
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _showMobileDrawer(context),
            iconSize: DesignSystem.iconSizeMedium,
          ),
          const SizedBox(width: DesignSystem.spaceM),

          // Logo + Title
          Expanded(child: _buildLogo(context, compact: true)),

          // Trailing
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context, {bool compact = false}) {
    return Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Container(
          width: compact ? 36 : 44,
          height: compact ? 36 : 44,
          decoration: BoxDecoration(
            gradient: userRole != null
                ? DesignSystem.getRoleGradient(userRole!)
                : DesignSystem.primaryGradient,
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            boxShadow: DesignSystem.elevation2,
          ),
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 24,
          ),
        ),
        if (!compact) ...[
          const SizedBox(width: DesignSystem.spaceM),
          Text(
            title,
            style: DesignSystem.titleLarge(context).copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    GBNavItem item,
    int index,
    bool isMobile,
  ) {
    final isActive = currentIndex == index;
    final color = isActive
        ? (userRole != null
            ? DesignSystem.getRoleColor(userRole!)
            : DesignSystem.primaryBlue)
        : DesignSystem.textSecondary;

    if (isMobile) {
      return ListTile(
        leading: Icon(item.icon, color: color),
        title: Text(
          item.label,
          style: DesignSystem.bodyLarge(context).copyWith(
            color: isActive ? color : DesignSystem.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        trailing: item.badge != null ? _buildBadge(item.badge!) : null,
        selected: isActive,
        selectedTileColor: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        ),
        onTap: () {
          onItemTap(index);
          Navigator.pop(context); // Close drawer
        },
      );
    } else {
      return InkWell(
        onTap: () => onItemTap(index),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.spaceL,
            vertical: DesignSystem.spaceM,
          ),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, color: color, size: 20),
              const SizedBox(width: DesignSystem.spaceS),
              Text(
                item.label,
                style: DesignSystem.labelLarge(context).copyWith(
                  color: color,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (item.badge != null) ...[
                const SizedBox(width: DesignSystem.spaceS),
                _buildBadge(item.badge!),
              ],
            ],
          ),
        ),
      );
    }
  }

  Widget _buildBadge(String badge) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spaceS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: DesignSystem.error,
        borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
      ),
      child: Text(
        badge,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.spaceM,
          vertical: DesignSystem.spaceS,
        ),
        decoration: BoxDecoration(
          color: DesignSystem.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          border: Border.all(color: DesignSystem.getBorderColor(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: userRole != null
                  ? DesignSystem.getRoleColor(userRole!)
                  : DesignSystem.primaryBlue,
              child: Text(
                userName![0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: DesignSystem.spaceS),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName!,
                  style: DesignSystem.labelMedium(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (userRole != null)
                  Text(
                    userRole!.toUpperCase(),
                    style: DesignSystem.labelSmall(context),
                  ),
              ],
            ),
            const SizedBox(width: DesignSystem.spaceS),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: const [
              Icon(Icons.person_outline, size: 20),
              SizedBox(width: DesignSystem.spaceM),
              Text('Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'settings',
          child: Row(
            children: const [
              Icon(Icons.settings_outlined, size: 20),
              SizedBox(width: DesignSystem.spaceM),
              Text('Settings'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: const [
              Icon(Icons.logout, size: 20, color: DesignSystem.error),
              SizedBox(width: DesignSystem.spaceM),
              Text('Logout', style: TextStyle(color: DesignSystem.error)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout' && onLogout != null) {
          onLogout!();
        }
        // Handle other menu items
      },
    );
  }

  void _showMobileDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: DesignSystem.getSurfaceColor(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignSystem.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: DesignSystem.spaceM),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DesignSystem.neutral300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // User header
              if (userName != null) ...[
                const SizedBox(height: DesignSystem.spaceL),
                ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: userRole != null
                        ? DesignSystem.getRoleColor(userRole!)
                        : DesignSystem.primaryBlue,
                    child: Text(
                      userName![0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    userName!,
                    style: DesignSystem.titleMedium(context),
                  ),
                  subtitle:
                      userRole != null ? Text(userRole!.toUpperCase()) : null,
                ),
                const Divider(),
              ],

              // Navigation items
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSystem.spaceL,
                    vertical: DesignSystem.spaceM,
                  ),
                  children: items.asMap().entries.map((entry) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: DesignSystem.spaceS),
                      child:
                          _buildNavItem(context, entry.value, entry.key, true),
                    );
                  }).toList(),
                ),
              ),

              // Logout button
              if (onLogout != null) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(DesignSystem.spaceL),
                  child: ListTile(
                    leading:
                        const Icon(Icons.logout, color: DesignSystem.error),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: DesignSystem.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onLogout!();
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation item model
class GBNavItem {
  final IconData icon;
  final String label;
  final String? badge;

  const GBNavItem({
    required this.icon,
    required this.label,
    this.badge,
  });
}

/// Usage Example:
///
/// GBNavigation(
///   title: 'GivingBridge',
///   currentIndex: _currentIndex,
///   onItemTap: (index) => setState(() => _currentIndex = index),
///   userName: 'John Doe',
///   userRole: 'donor',
///   onLogout: _handleLogout,
///   items: const [
///     GBNavItem(icon: Icons.dashboard, label: 'Overview'),
///     GBNavItem(icon: Icons.favorite, label: 'Donations', badge: '3'),
///     GBNavItem(icon: Icons.message, label: 'Messages'),
///   ],
/// )
