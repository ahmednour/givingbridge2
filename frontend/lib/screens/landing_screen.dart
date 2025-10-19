import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_button.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                title: Text(AppLocalizations.of(context)!.english),
                onTap: () {
                  _changeLanguage(context, const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇸🇦', style: TextStyle(fontSize: 24)),
                title: Text(AppLocalizations.of(context)!.arabic),
                onTap: () {
                  _changeLanguage(context, const Locale('ar'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage(BuildContext context, Locale locale) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    localeProvider.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),

            // Hero Section
            _buildHeroSection(context, theme, isDark, isDesktop),

            // Animated Stats Section
            _buildAnimatedStatsSection(context, theme, isDark, isDesktop),

            // Features Section
            _buildFeaturesSection(context, theme, isDark, isDesktop),

            // How It Works Section
            _buildHowItWorksSection(context, theme, isDark, isDesktop),

            // Featured Donations Section
            _buildFeaturedDonationsSection(context, theme, isDark, isDesktop),

            // Stats Section
            _buildStatsSection(context, theme, isDark, isDesktop),

            // Testimonials Section
            _buildTestimonialsSection(context, theme, isDark, isDesktop),

            // CTA Section
            _buildCTASection(context, theme, isDark, isDesktop),

            // Footer
            _buildFooter(context, theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor)
                .withOpacity(0.8),
            border: Border(
              bottom: BorderSide(
                color:
                    (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor)
                        .withOpacity(0.3),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Logo
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS + AppTheme.spacingXS),
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),

              const Spacer(),

              // Navigation buttons
              Row(
                children: [
                  // Language Switcher
                  Consumer<LocaleProvider>(
                    builder: (context, localeProvider, child) {
                      return TextButton.icon(
                        icon: const Icon(Icons.language, size: 20),
                        label: Text(
                          localeProvider.isArabic ? 'EN' : 'عربي',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        onPressed: () => _showLanguageDialog(context),
                      );
                    },
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  GBButton(
                    text: l10n.login,
                    variant: GBButtonVariant.ghost,
                    size: GBButtonSize.medium,
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                  const SizedBox(width: AppTheme.spacingS + AppTheme.spacingXS),
                  GBPrimaryButton(
                    text: l10n.getStarted,
                    size: GBButtonSize.medium,
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? AppTheme.spacingXXL + AppTheme.spacingM
            : AppTheme.spacingL,
        vertical: isDesktop
            ? AppTheme.spacingXXL + AppTheme.spacingM
            : AppTheme.spacingXXL,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.05),
            AppTheme.secondaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              if (isDesktop)
                Row(
                  children: [
                    Expanded(child: _buildHeroContent(theme, isDesktop, l10n)),
                    const SizedBox(
                        width: AppTheme.spacingXXL + AppTheme.spacingM),
                    Expanded(child: _buildHeroIllustration(isDark)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildHeroContent(theme, isDesktop, l10n),
                    const SizedBox(height: AppTheme.spacingXXL),
                    _buildHeroIllustration(isDark),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroContent(
      ThemeData theme, bool isDesktop, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          l10n.connectHeartsShareHope,
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingL),
        Text(
          l10n.landingHeroDescription,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark
                ? AppTheme.darkTextSecondaryColor
                : AppTheme.textSecondaryColor,
            height: 1.6,
            fontSize: 18,
          ),
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingXL + AppTheme.spacingS),
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: GBPrimaryButton(
                  text: l10n.startDonating,
                  size: GBButtonSize.large,
                  leftIcon: const Icon(Icons.favorite, size: 20),
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  fullWidth: true,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: GBOutlineButton(
                  text: l10n.learnMore,
                  size: GBButtonSize.large,
                  leftIcon: const Icon(Icons.play_circle_outline, size: 20),
                  onPressed: () {},
                  fullWidth: true,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              GBPrimaryButton(
                text: l10n.startDonating,
                size: GBButtonSize.large,
                fullWidth: true,
                leftIcon: const Icon(Icons.favorite, size: 20),
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
              const SizedBox(height: AppTheme.spacingM),
              GBOutlineButton(
                text: l10n.learnMore,
                size: GBButtonSize.large,
                fullWidth: true,
                leftIcon: const Icon(Icons.play_circle_outline, size: 20),
                onPressed: () {},
              ),
            ],
          ),

        // Feature icons section (like in the image)
        const SizedBox(height: AppTheme.spacingXL),
        Row(
          mainAxisAlignment:
              isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            _buildHeroFeature(
              icon: Icons.people,
              label: 'عدد المتبرعين',
              isDark: isDark,
            ),
            SizedBox(width: isDesktop ? AppTheme.spacingXL : AppTheme.spacingL),
            _buildHeroFeature(
              icon: Icons.attach_money,
              label: 'إجمالي التبرعات',
              isDark: isDark,
            ),
            SizedBox(width: isDesktop ? AppTheme.spacingXL : AppTheme.spacingL),
            _buildHeroFeature(
              icon: Icons.verified_user,
              label: l10n.secure100,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroFeature({
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark
              ? AppTheme.darkTextSecondaryColor
              : AppTheme.textSecondaryColor,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppTheme.darkTextSecondaryColor
                : AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroIllustration(bool isDark) {
    return Stack(
      children: [
        // Main image - Hands holding (black & white aesthetic)
        Container(
          height: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade400,
                  ],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Real hero image from local assets
                  Image.asset(
                    'assets/images/hero/hero-hands.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to gradient if image not found
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.grey.shade800,
                              Colors.grey.shade600,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.volunteer_activism,
                            size: 200,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      );
                    },
                  ),
                  // Dark overlay for better text contrast
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Floating badge - Top Left: "donations today 25+"
        Positioned(
          top: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: AppTheme.spacingM,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '8 donations today',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating badge - Bottom Right: "people helped 150"
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: AppTheme.spacingM,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '67 people helped',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedStatsSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;

    final stats = [
      {
        'value': '847',
        'label': l10n.totalDonations,
        'icon': Icons.favorite,
        'color': const Color(0xFFEC4899), // Pink
        'trend': l10n.trendingUp,
      },
      {
        'value': '12',
        'label': l10n.communities,
        'icon': Icons.groups,
        'color': const Color(0xFF8B5CF6), // Purple
        'trend': l10n.newCommunities,
      },
      {
        'value': '234',
        'label': l10n.activeDonors,
        'icon': Icons.people,
        'color': const Color(0xFF06B6D4), // Cyan
        'trend': l10n.trendingUp24,
      },
      {
        'value': '94%',
        'label': l10n.successRate,
        'icon': Icons.check_circle,
        'color': const Color(0xFF10B981), // Green
        'trend': l10n.trustedBadge,
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? AppTheme.spacingXXL + AppTheme.spacingM
            : AppTheme.spacingL,
        vertical: AppTheme.spacingXXL + AppTheme.spacingM,
      ),
      child: isDesktop
          ? Row(
              children: stats
                  .map((stat) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM),
                          child: _buildStatCard(stat, theme, isDark),
                        ),
                      ))
                  .toList(),
            )
          : Column(
              children: stats
                  .map((stat) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingL),
                        child: _buildStatCard(stat, theme, isDark),
                      ))
                  .toList(),
            ),
    );
  }

  Widget _buildStatCard(
      Map<String, dynamic> stat, ThemeData theme, bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (isDark ? Colors.grey.shade900 : Colors.white),
                    (isDark
                        ? Colors.grey.shade900
                        : stat['color'].withOpacity(0.02)),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                border: Border.all(
                  color: stat['color'].withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: stat['color'].withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingM),
                    decoration: BoxDecoration(
                      color: stat['color'].withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    ),
                    child: Icon(
                      stat['icon'],
                      color: stat['color'],
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),

                  // Value with animation
                  Text(
                    stat['value'],
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 36,
                      color: isDark
                          ? AppTheme.darkTextPrimaryColor
                          : AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),

                  // Label
                  Text(
                    stat['label'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextSecondaryColor
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),

                  // Trend indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingM,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 14,
                          color: Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stat['trend'],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      {
        'icon': Icons.favorite_outline,
        'title': l10n.easyDonations,
        'description': l10n.easyDonationsDesc,
        'color': const Color(0xFFEC4899), // Pink
        'lightColor': const Color(0xFFFCE7F3),
        'badge': l10n.popularBadge,
        'badgeColor': const Color(0xFFEF4444),
      },
      {
        'icon': Icons.search_outlined,
        'title': l10n.smartMatching,
        'description': l10n.smartMatchingDesc,
        'color': const Color(0xFF8B5CF6), // Purple
        'lightColor': const Color(0xFFF3E8FF),
        'badge': l10n.aiPoweredBadge,
        'badgeColor': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': l10n.verifiedUsers,
        'description': l10n.verifiedUsersDesc,
        'color': const Color(0xFF06B6D4), // Cyan
        'lightColor': const Color(0xFFCFFAFE),
        'badge': l10n.verifiedBadge,
        'badgeColor': const Color(0xFF06B6D4),
      },
      {
        'icon': Icons.analytics_outlined,
        'title': l10n.impactTracking,
        'description': l10n.impactTrackingDesc,
        'color': const Color(0xFF10B981), // Green
        'lightColor': const Color(0xFFD1FAE5),
        'badge': l10n.realtimeBadge,
        'badgeColor': const Color(0xFF10B981),
      },
      {
        'icon': Icons.security_outlined,
        'title': l10n.securePlatform,
        'description': l10n.securePlatformDesc,
        'color': const Color(0xFFF59E0B), // Orange
        'lightColor': const Color(0xFFFEF3C7),
        'badge': l10n.secureBadge,
        'badgeColor': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': l10n.support247,
        'description': l10n.support247Desc,
        'color': const Color(0xFF6366F1), // Indigo
        'lightColor': const Color(0xFFE0E7FF),
        'badge': l10n.newBadge,
        'badgeColor': const Color(0xFF6366F1),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? AppTheme.spacingXXL + AppTheme.spacingM
            : AppTheme.spacingL,
        vertical: AppTheme.spacingXXL + AppTheme.spacingM,
      ),
      child: Column(
        children: [
          Text(
            l10n.whyChooseGivingBridge,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            l10n.platformDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          if (isDesktop)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    3, // Changed from 4 to 3 for 6 cards (2 rows of 3)
                crossAxisSpacing: AppTheme.spacingXL,
                mainAxisSpacing: AppTheme.spacingXL,
                childAspectRatio: 1.0, // Adjusted for better proportions
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return _buildFeatureCard(feature, theme, isDark);
              },
            )
          else
            Column(
              children: features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
                  child: _buildFeatureCard(feature, theme, isDark),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      Map<String, dynamic> feature, ThemeData theme, bool isDark) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(
            color: isDark
                ? AppTheme.darkBorderColor
                : AppTheme.borderColor.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: feature['color'].withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge at the top
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Container with Gradient
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        feature['color'].withOpacity(0.8),
                        feature['color'],
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: feature['color'].withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.15,
                          child: CustomPaint(
                            painter: _DotPatternPainter(),
                          ),
                        ),
                      ),
                      // Icon
                      Center(
                        child: Icon(
                          feature['icon'],
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: feature['badgeColor'].withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: feature['badgeColor'].withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    feature['badge'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: feature['badgeColor'],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),

            // Title
            Text(
              feature['title'],
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                height: 1.3,
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Description
            Expanded(
              child: Text(
                feature['description'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                  height: 1.6,
                  fontSize: 14,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Decorative gradient bar at the bottom
            const SizedBox(height: AppTheme.spacingM),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    feature['color'],
                    feature['color'].withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorksSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final steps = [
      {
        'number': '1',
        'title': l10n.stepSignUp,
        'description': l10n.stepSignUpDesc,
        'icon': Icons.person_add_outlined,
        'gradient': [const Color(0xFFEC4899), const Color(0xFFF472B6)], // Pink
      },
      {
        'number': '2',
        'title': l10n.stepBrowseOrPost,
        'description': l10n.stepBrowseOrPostDesc,
        'icon': Icons.inventory_outlined,
        'gradient': [
          const Color(0xFF8B5CF6),
          const Color(0xFFA78BFA)
        ], // Purple
      },
      {
        'number': '3',
        'title': l10n.stepConnect,
        'description': l10n.stepConnectDesc,
        'icon': Icons.connect_without_contact_outlined,
        'gradient': [const Color(0xFF06B6D4), const Color(0xFF22D3EE)], // Cyan
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? AppTheme.spacingXXL + AppTheme.spacingM
            : AppTheme.spacingL,
        vertical: AppTheme.spacingXXL + AppTheme.spacingM,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor)
                .withOpacity(0.3),
            (isDark ? AppTheme.darkSurfaceColor : Colors.white)
                .withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            l10n.howItWorks,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            AppLocalizations.of(context)!.simpleSteps,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.map((step) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM),
                    child: _buildStepCard(step, theme, isDark),
                  ),
                );
              }).toList(),
            )
          else
            Column(
              children: steps.map((step) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
                  child: _buildStepCard(step, theme, isDark),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
      Map<String, dynamic> step, ThemeData theme, bool isDark) {
    final gradient = step['gradient'] as List;
    final color1 = gradient[0] as Color;
    final color2 = gradient[1] as Color;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color1.withOpacity(0.1),
            color2.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: color1.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon with gradient background
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color1, color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color1.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Icon
                Center(
                  child: Icon(
                    step['icon'],
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                // Number badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        step['number'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: color1,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingXL),

          // Title
          Text(
            step['title'],
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Description
          Text(
            step['description'],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
              height: 1.6,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final stats = [
      {'number': '10,000+', 'label': l10n.itemsDonated},
      {'number': '5,000+', 'label': l10n.happyRecipients},
      {'number': '50+', 'label': l10n.citiesCovered},
      {'number': '95%', 'label': l10n.successRate},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? AppTheme.spacingXXL + AppTheme.spacingM
            : AppTheme.spacingL,
        vertical: AppTheme.spacingXXL + AppTheme.spacingM,
      ),
      child: Column(
        children: [
          Text(
            l10n.ourImpactInNumbers,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          if (isDesktop)
            Row(
              children: stats.map((stat) {
                return Expanded(
                  child: _buildStatsDisplayCard(stat, theme),
                );
              }).toList(),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.spacingM,
                mainAxisSpacing: AppTheme.spacingM,
                childAspectRatio: 1.5,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                return _buildStatsDisplayCard(stats[index], theme);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatsDisplayCard(Map<String, String> stat, ThemeData theme) {
    return Column(
      children: [
        Text(
          stat['number']!,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          stat['label']!,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTestimonialsSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final testimonials = [
      {
        'name': 'Sarah M.',
        'role': 'Donor • 6 months',
        'image':
            'https://ui-avatars.com/api/?name=Sarah+M&background=EC4899&color=fff&size=128&bold=true',
        'rating': 5,
        'text': l10n.testimonial1Text,
        'color': const Color(0xFFEC4899),
      },
      {
        'name': 'Ahmed K.',
        'role': 'Community Volunteer • 1 year',
        'image':
            'https://ui-avatars.com/api/?name=Ahmed+K&background=8B5CF6&color=fff&size=128&bold=true',
        'rating': 5,
        'text': l10n.testimonial2Text,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'name': 'Layla H.',
        'role': 'Single Parent • New User',
        'image':
            'https://ui-avatars.com/api/?name=Layla+H&background=10B981&color=fff&size=128&bold=true',
        'rating': 5,
        'text': l10n.testimonial3Text,
        'color': const Color(0xFF10B981),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? AppTheme.spacingXXL + AppTheme.spacingM
            : AppTheme.spacingL,
        vertical: AppTheme.spacingXXL + AppTheme.spacingM,
      ),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.darkSurfaceColor : Colors.grey.shade50)
            .withOpacity(0.5),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.whatCommunitySays,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            AppLocalizations.of(context)!.realStories,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: testimonials
                  .map((testimonial) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM),
                          child:
                              _buildTestimonialCard(testimonial, theme, isDark),
                        ),
                      ))
                  .toList(),
            )
          else
            Column(
              children: testimonials
                  .map((testimonial) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spacingL),
                        child:
                            _buildTestimonialCard(testimonial, theme, isDark),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(
      Map<String, dynamic> testimonial, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: testimonial['color'].withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: testimonial['color'].withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and rating
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: testimonial['color'].withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    testimonial['image'],
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to gradient with initials if image fails
                      return Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              testimonial['color'].withOpacity(0.8),
                              testimonial['color'],
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            testimonial['name'].substring(0, 1),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial['name'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      testimonial['role'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Rating stars
          Row(
            children: List.generate(
              testimonial['rating'] as int,
              (index) => Icon(
                Icons.star,
                size: 18,
                color: const Color(0xFFFBBF24),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),

          // Quote icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: testimonial['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.format_quote,
              color: testimonial['color'],
              size: 24,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),

          // Testimonial text
          Text(
            testimonial['text'],
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontSize: 15,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? AppTheme.spacingXXL + AppTheme.spacingM
            : AppTheme.spacingL,
        vertical: AppTheme.spacingXXL,
      ),
      padding: EdgeInsets.all(
        isDesktop
            ? AppTheme.spacingXXL + AppTheme.spacingL
            : AppTheme.spacingXXL,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF3B82F6), // Blue
            Color(0xFF8B5CF6), // Purple
            Color(0xFF10B981), // Green
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.readyToMakeADifference,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            l10n.joinThousands,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL + AppTheme.spacingS),
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXXL,
                      vertical: AppTheme.spacingL,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.startDonating,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingL),
                OutlinedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXXL,
                      vertical: AppTheme.spacingL,
                    ),
                    side: const BorderSide(color: Colors.white, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.explore, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.browseDonationsAction,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8B5CF6),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.startDonating,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                GBOutlineButton(
                  text: l10n.browseDonationsAction,
                  size: GBButtonSize.large,
                  fullWidth: true,
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturedDonationsSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;

    // Sample featured donations with realistic data
    final donations = [
      {
        'title': 'Winter Clothes - Kids Size 6-10',
        'category': 'Clothes',
        'condition': 'Like New',
        'donorName': 'Community Center',
        'location': 'Downtown, Cairo',
        'isNew': true,
        'image': Icons.checkroom,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'title': 'Calculus & Physics Textbooks',
        'category': 'Books',
        'condition': 'Good',
        'donorName': 'University Graduate',
        'location': 'Maadi, Cairo',
        'isNew': false,
        'image': Icons.menu_book,
        'color': const Color(0xFF06B6D4),
      },
      {
        'title': 'Rice & Canned Goods (15kg)',
        'category': 'Food',
        'condition': 'New',
        'donorName': 'Local Business',
        'location': 'Nasr City',
        'isNew': true,
        'image': Icons.restaurant,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Dell Laptop - Core i5, 8GB RAM',
        'category': 'Electronics',
        'condition': 'Good',
        'donorName': 'IT Professional',
        'location': 'New Cairo',
        'isNew': false,
        'image': Icons.laptop_mac,
        'color': const Color(0xFFF59E0B),
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop
            ? AppTheme.spacingXXL + AppTheme.spacingM
            : AppTheme.spacingL,
        vertical: AppTheme.spacingXXL + AppTheme.spacingM,
      ),
      child: Column(
        children: [
          Text(
            l10n.featuredDonations,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            l10n.featuredDonationsDesc,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXXL),

          if (isDesktop)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: AppTheme.spacingL,
                mainAxisSpacing: AppTheme.spacingL,
                childAspectRatio: 0.8,
              ),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                return _buildDonationCard(
                    donations[index], theme, isDark, l10n);
              },
            )
          else
            Column(
              children: donations.map((donation) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
                  child: _buildDonationCard(donation, theme, isDark, l10n),
                );
              }).toList(),
            ),

          const SizedBox(height: AppTheme.spacingXL),

          // Call to Action Button
          GBOutlineButton(
            text: l10n.viewAllDonations,
            size: GBButtonSize.large,
            onPressed: () => Navigator.pushNamed(context, '/login'),
            rightIcon: const Icon(Icons.arrow_forward, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation, ThemeData theme,
      bool isDark, AppLocalizations l10n) {
    // Get initials from donor name for avatar
    String getInitials(String name) {
      List<String> names = name.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(
            color: isDark
                ? AppTheme.darkBorderColor
                : AppTheme.borderColor.withOpacity(0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: donation['color'].withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image/Icon Section - Enhanced
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    donation['color'].withOpacity(0.7),
                    donation['color'],
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusXL),
                  topRight: Radius.circular(AppTheme.radiusXL),
                ),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: CustomPaint(
                        painter: _DotPatternPainter(),
                      ),
                    ),
                  ),
                  // Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        donation['image'],
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // New Badge
                  if (donation['isNew'])
                    Positioned(
                      top: AppTheme.spacingM,
                      right: AppTheme.spacingM,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.successColor.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.fiber_new,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.newLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Section - Enhanced
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          donation['title'],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppTheme.spacingM),

                        // Category & Condition
                        Wrap(
                          spacing: AppTheme.spacingS,
                          runSpacing: AppTheme.spacingS,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: donation['color'].withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    donation['image'],
                                    size: 12,
                                    color: donation['color'],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    donation['category'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: donation['color'],
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingM,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade100),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                donation['condition'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppTheme.darkTextSecondaryColor
                                      : AppTheme.textSecondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Donor Info - Fixed with proper avatar
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: (isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade50),
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      child: Row(
                        children: [
                          // Donor Avatar with Initials
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  donation['color'].withOpacity(0.8),
                                  donation['color'],
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: donation['color'].withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                getInitials(donation['donorName']),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donation['donorName'],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 11,
                                      color: isDark
                                          ? AppTheme.darkTextSecondaryColor
                                          : AppTheme.textSecondaryColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Expanded(
                                      child: Text(
                                        donation['location'],
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: isDark
                                              ? AppTheme.darkTextSecondaryColor
                                              : AppTheme.textSecondaryColor,
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                l10n.appTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            l10n.copyright,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            l10n.madeWithLove,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for dot pattern background
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 2.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
