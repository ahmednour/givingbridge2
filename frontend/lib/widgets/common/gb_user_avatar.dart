import 'package:flutter/material.dart';
import '../../core/theme/design_system.dart';
import '../../core/config/api_config.dart';

/// A reusable user avatar widget that displays either:
/// - User's uploaded avatar image
/// - User's initials in a colored circle
class GBUserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String userName;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;

  const GBUserAvatar({
    Key? key,
    this.avatarUrl,
    required this.userName,
    this.size = 40,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(userName);
    final bgColor =
        backgroundColor ?? DesignSystem.primaryBlue.withValues(alpha: 0.1);
    final txtColor = textColor ?? DesignSystem.primaryBlue;
    final fontSz = fontSize ?? (size * 0.4);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: Image.network(
                _getFullAvatarUrl(avatarUrl!),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to initials if image fails to load
                  return _buildInitialsAvatar(initials, txtColor, fontSz);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildInitialsAvatar(initials, txtColor, fontSz);
                },
              ),
            )
          : _buildInitialsAvatar(initials, txtColor, fontSz),
    );
  }

  Widget _buildInitialsAvatar(String initials, Color color, double fontSize) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';

    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      // First and last name initials
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    } else {
      // Just first letter
      return name[0].toUpperCase();
    }
  }

  String _getFullAvatarUrl(String avatarUrl) {
    // If it's already a full URL, return as is
    if (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://')) {
      return avatarUrl;
    }

    // Otherwise, construct full URL with base URL
    final baseUrl = ApiConfig.baseUrl;

    // Remove leading slash if present to avoid double slashes
    final cleanPath = avatarUrl.startsWith('/') ? avatarUrl : '/$avatarUrl';

    return '$baseUrl$cleanPath';
  }
}
