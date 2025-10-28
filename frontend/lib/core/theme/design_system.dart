import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// GivingBridge Enhanced Design System
/// Material 3 inspired design tokens for a modern, accessible donation platform
class DesignSystem {
  // ========== COLOR PALETTE ==========

  /// Primary Colors (Trust & Professionalism)
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color primaryBlueLight = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);

  /// Secondary Colors (Growth & Hope)
  static const Color secondaryGreen = Color(0xFF10B981);
  static const Color secondaryGreenLight = Color(0xFF34D399);
  static const Color secondaryGreenDark = Color(0xFF059669);

  /// Accent Colors (Warmth & Engagement)
  static const Color accentPink = Color(0xFFEC4899); // Empathetic, caring
  static const Color accentPurple = Color(0xFF8B5CF6); // Creative, supportive
  static const Color accentAmber = Color(0xFFF59E0B); // Warmth, energy
  static const Color accentCyan = Color(0xFF06B6D4); // Trust, clarity

  /// Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  /// Neutral Colors - Light Mode
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  /// Surface Colors - Light Mode
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color cardLight = Color(0xFFFFFFFF);

  /// Text Colors - Light Mode
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textDisabled = Color(0xFFD1D5DB);

  /// Border & Divider Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color divider = Color(0xFFF3F4F6);

  /// Dark Mode Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color borderDark = Color(0xFF475569);

  // ========== GRADIENTS ==========

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient donorGradient = LinearGradient(
    colors: [accentPink, Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient receiverGradient = LinearGradient(
    colors: [secondaryGreen, secondaryGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient adminGradient = LinearGradient(
    colors: [accentAmber, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFF2563EB),
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== SPACING SYSTEM ==========

  /// Micro spacing (2px)
  static const double spaceXXS = 2.0;

  /// Extra small spacing (4px)
  static const double spaceXS = 4.0;

  /// Small spacing (8px)
  static const double spaceS = 8.0;

  /// Medium spacing (16px) - Base unit
  static const double spaceM = 16.0;

  /// Large spacing (24px)
  static const double spaceL = 24.0;

  /// Extra large spacing (32px)
  static const double spaceXL = 32.0;

  /// Extra extra large spacing (48px)
  static const double spaceXXL = 48.0;

  /// Extra extra extra large spacing (64px)
  static const double spaceXXXL = 64.0;

  /// Responsive padding based on screen width
  static double getResponsivePadding(double width) {
    if (width < 480) return spaceM;
    if (width < 768) return spaceL;
    if (width < 1024) return spaceXL;
    return spaceXXL;
  }

  // ========== BORDER RADIUS ==========

  static const double radiusXS = 4.0;
  static const double radiusS = 6.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  static const double radiusPill = 999.0;

  // ========== ELEVATION & SHADOWS ==========

  static List<BoxShadow> get elevationNone => [];

  static List<BoxShadow> get elevation1 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get elevation2 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 6,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevation3 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 10,
          spreadRadius: -3,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get elevation4 => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          spreadRadius: -4,
          offset: const Offset(0, 12),
        ),
      ];

  /// Colored shadows for emphasis
  static List<BoxShadow> coloredShadow(Color color, {double opacity = 0.3}) => [
        BoxShadow(
          color: color.withValues(alpha: opacity),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ];

  // ========== TYPOGRAPHY SCALE (Material 3) ==========

  /// Display styles (Hero sections, major headings)
  static TextStyle displayLarge(BuildContext context) => GoogleFonts.cairo(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        color: _getTextColor(context),
        height: 1.12,
      );

  static TextStyle displayMedium(BuildContext context) => GoogleFonts.cairo(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: _getTextColor(context),
        height: 1.16,
      );

  static TextStyle displaySmall(BuildContext context) => GoogleFonts.cairo(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: _getTextColor(context),
        height: 1.22,
      );

  /// Headline styles (Section titles)
  static TextStyle headlineLarge(BuildContext context) => GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: _getTextColor(context),
        height: 1.25,
      );

  static TextStyle headlineMedium(BuildContext context) => GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: _getTextColor(context),
        height: 1.29,
      );

  static TextStyle headlineSmall(BuildContext context) => GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: _getTextColor(context),
        height: 1.33,
      );

  /// Title styles (Card titles, important labels)
  static TextStyle titleLarge(BuildContext context) => GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: _getTextColor(context),
        height: 1.27,
      );

  static TextStyle titleMedium(BuildContext context) => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        color: _getTextColor(context),
        height: 1.5,
      );

  static TextStyle titleSmall(BuildContext context) => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: _getTextColor(context),
        height: 1.43,
      );

  /// Body styles (Content text)
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: _getTextColor(context),
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        color: _getTextColor(context),
        height: 1.43,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        color: _getTextSecondaryColor(context),
        height: 1.33,
      );

  /// Label styles (Tags, captions, buttons)
  static TextStyle labelLarge(BuildContext context) => GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: _getTextColor(context),
        height: 1.43,
      );

  static TextStyle labelMedium(BuildContext context) => GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _getTextColor(context),
        height: 1.33,
      );

  static TextStyle labelSmall(BuildContext context) => GoogleFonts.cairo(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: _getTextSecondaryColor(context),
        height: 1.45,
      );

  // ========== ANIMATION DURATIONS ==========

  static const Duration microDuration = Duration(milliseconds: 100);
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 400);
  static const Duration longDuration = Duration(milliseconds: 600);

  // ========== ANIMATION CURVES ==========

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;
  static const Curve emphasizedCurve = Curves.easeInOutCubic;

  // ========== BREAKPOINTS ==========

  static const double mobileSmall = 360;
  static const double mobileMedium = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double desktopLarge = 1440;
  static const double desktopXL = 1920;

  /// Check if current width is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }

  /// Check if current width is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }

  /// Check if current width is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  // ========== TOUCH TARGETS ==========

  static const double minTouchTarget = 48.0;
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // ========== HELPER METHODS ==========

  static Color _getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimary;
  }

  static Color _getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondary;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? surfaceDark
        : surfaceLight;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color getBorderColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? borderDark
        : border;
  }

  /// Get role-specific gradient
  static LinearGradient getRoleGradient(String role) {
    switch (role.toLowerCase()) {
      case 'donor':
        return donorGradient;
      case 'receiver':
        return receiverGradient;
      case 'admin':
        return adminGradient;
      default:
        return primaryGradient;
    }
  }

  /// Get role-specific color
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'donor':
        return accentPink;
      case 'receiver':
        return secondaryGreen;
      case 'admin':
        return accentAmber;
      default:
        return primaryBlue;
    }
  }
}
