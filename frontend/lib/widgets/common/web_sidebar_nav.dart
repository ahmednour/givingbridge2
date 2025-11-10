import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/design_system.dart';
import '../../core/theme/web_theme.dart';
import '../../l10n/app_localizations.dart';

class WebSidebarNav extends StatefulWidget {
  final String currentRoute;
  final List<WebNavItem> items;
  final Widget? userSection;
  final VoidCallback? onLogout;
  final bool isCollapsed;
  final ValueChanged<bool>? onCollapseChanged;

  const WebSidebarNav({
    Key? key,
    required this.currentRoute,
    required this.items,
    this.userSection,
    this.onLogout,
    this.isCollapsed = false,
    this.onCollapseChanged,
  }) : super(key: key);

  @override
  State<WebSidebarNav> createState() => _WebSidebarNavState();
}

class _WebSidebarNavState extends State<WebSidebarNav> {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.isCollapsed;
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
    widget.onCollapseChanged?.call(_isCollapsed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: _isCollapsed ? 72 : 280,
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        border: Border(
          right: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with logo and collapse button
          _buildHeader(),

          // User section (if provided)
          if (widget.userSection != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    _isCollapsed ? DesignSystem.spaceS : DesignSystem.spaceL,
                vertical: DesignSystem.spaceM,
              ),
              child: widget.userSection!,
            ),
            Divider(
              color: DesignSystem.getBorderColor(context),
              height: 1,
            ),
          ],

          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: DesignSystem.spaceM),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return _buildNavItem(item, index);
              },
            ),
          ),

          // Logout button (if provided)
          if (widget.onLogout != null) ...[
            Divider(
              color: DesignSystem.getBorderColor(context),
              height: 1,
            ),
            _buildLogoutButton(),
          ],

          const SizedBox(height: DesignSystem.spaceM),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Container(
      height: WebTheme.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: DesignSystem.spaceL),
      child: Row(
        children: [
          if (!_isCollapsed) ...[
            // Logo with gradient
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignSystem.primaryBlue,
                    DesignSystem.primaryBlue.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.volunteer_activism,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: DesignSystem.spaceM),
            Expanded(
              child: Text(AppLocalizations.of(context)!.givingBridge,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  )),
            ),
          ] else ...[
            // Collapsed logo only
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignSystem.primaryBlue,
                    DesignSystem.primaryBlue.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.volunteer_activism,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
          const SizedBox(width: DesignSystem.spaceS),
          // Collapse toggle button
          IconButton(
            icon: Icon(
              _isCollapsed ? Icons.menu : Icons.menu_open,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: _toggleCollapse,
            tooltip: _isCollapsed ? 'Expand' : 'Collapse',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(WebNavItem item, int index) {
    final isActive = widget.currentRoute == item.route;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _isCollapsed ? DesignSystem.spaceXS : DesignSystem.spaceM,
        vertical: DesignSystem.spaceXS,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: item.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal:
                  _isCollapsed ? DesignSystem.spaceM : DesignSystem.spaceL,
              vertical: DesignSystem.spaceM,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? item.color.withOpacity(isDark ? 0.2 : 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isActive ? item.color.withOpacity(0.3) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isActive
                      ? item.color
                      : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                if (!_isCollapsed) ...[
                  const SizedBox(width: DesignSystem.spaceM),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isActive ? item.color : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
                if (!_isCollapsed && item.badge != null) ...[
                  const SizedBox(width: DesignSystem.spaceS),
                  _buildBadge(item.badge!, item.color),
                ],
              ],
            ),
          ),
        ),
      )
          .animate(delay: Duration(milliseconds: 100 + (index * 50)))
          .fadeIn(duration: 400.ms)
          .slideX(begin: -0.2, end: 0),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spaceS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _isCollapsed ? DesignSystem.spaceXS : DesignSystem.spaceM,
        vertical: DesignSystem.spaceM,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onLogout,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal:
                  _isCollapsed ? DesignSystem.spaceM : DesignSystem.spaceL,
              vertical: DesignSystem.spaceM,
            ),
            decoration: BoxDecoration(
              color: DesignSystem.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DesignSystem.error.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  color: DesignSystem.error,
                  size: 24,
                ),
                if (!_isCollapsed) ...[
                  const SizedBox(width: DesignSystem.spaceM),
                  Expanded(
                    child: Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: DesignSystem.error,
                      ),
                    ),
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

class WebNavItem {
  final String route;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const WebNavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });
}

// Bottom Navigation for mobile
class WebBottomNav extends StatelessWidget {
  final String currentRoute;
  final List<WebNavItem> items;

  const WebBottomNav({
    Key? key,
    required this.currentRoute,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            items.map((item) => _buildBottomNavItem(context, item)).toList(),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, WebNavItem item) {
    final isActive = currentRoute == item.route;

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: item.onTap,
          child: Container(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      item.icon,
                      color: isActive
                          ? item.color
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 26,
                    ),
                    if (item.badge != null)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.badge!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? item.color
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
