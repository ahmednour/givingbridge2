import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/design_system.dart';
import '../core/theme/web_theme.dart';
import '../widgets/common/web_button.dart';
import '../widgets/common/web_card.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  final GlobalKey _howItWorksKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToHowItWorks() {
    final context = _howItWorksKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      );
    }
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

  void _showMobileMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMobileDrawer(context, l10n, isDark),
    );
  }

  Widget _buildMobileDrawer(
      BuildContext context, AppLocalizations l10n, bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DesignSystem.radiusXL),
          topRight: Radius.circular(DesignSystem.radiusXL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.spaceL,
            vertical: DesignSystem.spaceXL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    label: 'Navigation menu',
                    header: true,
                    child: Text(
                      'Menu',
                      style: DesignSystem.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Close menu',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignSystem.spaceL),
              const Divider(),
              const SizedBox(height: DesignSystem.spaceM),

              // Dark Mode Toggle
              Semantics(
                label: 'Theme setting: ${isDark ? "Dark mode" : "Light mode"}',
                child: ListTile(
                  leading: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: DesignSystem.primaryBlue,
                  ),
                  title: Text(
                    isDark ? 'Light Mode' : 'Dark Mode',
                    style: DesignSystem.bodyLarge(context),
                  ),
                  subtitle: Text(
                    'Switch theme',
                    style: DesignSystem.bodySmall(context),
                  ),
                  trailing: Semantics(
                    label: 'Toggle theme',
                    button: true,
                    child: Switch(
                      value: isDark,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  onTap: () {
                    themeProvider.toggleTheme();
                    Navigator.pop(context);
                  },
                ),
              ),

              const Divider(),

              // Language Switcher
              Semantics(
                label:
                    'Language setting: ${localeProvider.isArabic ? "Arabic" : "English"}',
                child: ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: DesignSystem.primaryBlue,
                  ),
                  title: Text(
                    l10n.language,
                    style: DesignSystem.bodyLarge(context),
                  ),
                  subtitle: Text(
                    localeProvider.isArabic ? 'العربية' : 'English',
                    style: DesignSystem.bodySmall(context),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    _showLanguageDialog(context);
                  },
                ),
              ),

              const Divider(),
              const SizedBox(height: DesignSystem.spaceM),

              // Login Button
              Semantics(
                label: 'Navigate to login page',
                button: true,
                child: WebButton(
                  text: l10n.login,
                  icon: Icons.login,
                  variant: WebButtonVariant.outline,
                  size: WebButtonSize.large,
                  fullWidth: true,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ),

              const SizedBox(height: DesignSystem.spaceM),

              // Get Started Button
              Semantics(
                label: 'Navigate to registration page',
                button: true,
                child: WebButton(
                  text: l10n.getStarted,
                  icon: Icons.arrow_forward,
                  variant: WebButtonVariant.primary,
                  size: WebButtonSize.large,
                  fullWidth: true,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/register');
                  },
                ),
              ),

              const SizedBox(height: DesignSystem.spaceL),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
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
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= DesignSystem.desktop;

    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getSurfaceColor(context).withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 1,
          ),
        ),
        boxShadow: WebTheme.cardShadow,
      ),
      child: WebTheme.section(
        maxWidth: WebTheme.maxContentWidthLarge,
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.spaceXL,
          vertical: DesignSystem.spaceM,
        ),
        child: Row(
          children: [
            // Logo
            Semantics(
              label: '${l10n.appTitle} logo and home',
              button: true,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: DesignSystem.primaryGradient,
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                      boxShadow: DesignSystem.coloredShadow(
                        DesignSystem.primaryBlue,
                        opacity: 0.2,
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  Text(
                    l10n.appTitle,
                    style: DesignSystem.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Navigation buttons
            if (isDesktop) ...[
              Row(
                children: [
                  // Dark Mode Toggle
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Semantics(
                        label: isDark
                            ? 'Switch to light mode'
                            : 'Switch to dark mode',
                        button: true,
                        hint: 'Tap to toggle theme',
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: InkWell(
                            onTap: () => themeProvider.toggleTheme(),
                            borderRadius:
                                BorderRadius.circular(DesignSystem.radiusM),
                            child: Container(
                              padding:
                                  const EdgeInsets.all(DesignSystem.spaceS),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: DesignSystem.getBorderColor(context),
                                ),
                                borderRadius:
                                    BorderRadius.circular(DesignSystem.radiusM),
                              ),
                              child: Icon(
                                isDark ? Icons.light_mode : Icons.dark_mode,
                                size: 20,
                                color: DesignSystem.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  // Language Switcher
                  Consumer<LocaleProvider>(
                    builder: (context, localeProvider, child) {
                      final currentLang =
                          localeProvider.isArabic ? 'Arabic' : 'English';
                      return Semantics(
                        label: 'Change language, current: $currentLang',
                        button: true,
                        hint: 'Tap to switch language',
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: InkWell(
                            onTap: () => _showLanguageDialog(context),
                            borderRadius:
                                BorderRadius.circular(DesignSystem.radiusM),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignSystem.spaceM,
                                vertical: DesignSystem.spaceS,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: DesignSystem.getBorderColor(context),
                                ),
                                borderRadius:
                                    BorderRadius.circular(DesignSystem.radiusM),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.language, size: 20),
                                  const SizedBox(width: DesignSystem.spaceS),
                                  Text(
                                    localeProvider.isArabic ? 'EN' : 'عربي',
                                    style: DesignSystem.labelLarge(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  WebButton(
                    text: l10n.login,
                    variant: WebButtonVariant.ghost,
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                  ),
                  const SizedBox(width: DesignSystem.spaceM),
                  WebButton(
                    text: l10n.getStarted,
                    variant: WebButtonVariant.primary,
                    icon: Icons.arrow_forward,
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  // Dark Mode Toggle for Mobile
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Semantics(
                        label: isDark
                            ? 'Switch to light mode'
                            : 'Switch to dark mode',
                        button: true,
                        child: IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                          ),
                          onPressed: () => themeProvider.toggleTheme(),
                          tooltip: isDark ? 'Light mode' : 'Dark mode',
                        ),
                      );
                    },
                  ),
                  Semantics(
                    label: 'Open navigation menu',
                    button: true,
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => _showMobileMenu(context),
                      tooltip: 'Menu',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isLargeDesktop = size.width >= DesignSystem.desktopLarge;

    return Semantics(
      label: 'Hero section: ${l10n.connectHeartsShareHope}',
      container: true,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignSystem.primaryBlue.withOpacity(0.03),
              DesignSystem.secondaryGreen.withOpacity(0.03),
            ],
          ),
        ),
        child: WebTheme.section(
          maxWidth: WebTheme.maxContentWidthLarge,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? DesignSystem.spaceXXL : DesignSystem.spaceL,
            vertical: isDesktop
                ? WebTheme.sectionSpacingLarge
                : DesignSystem.spaceXXL,
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: isLargeDesktop ? 5 : 6,
                      child: _buildHeroContent(theme, isDesktop, l10n),
                    ),
                    const SizedBox(width: DesignSystem.spaceXXXL),
                    Expanded(
                      flex: isLargeDesktop ? 5 : 4,
                      child: _buildHeroIllustration(isDark),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildHeroContent(theme, isDesktop, l10n),
                    const SizedBox(height: DesignSystem.spaceXXL),
                    _buildHeroIllustration(isDark),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHeroContent(
      ThemeData theme, bool isDesktop, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        // Main headline
        Semantics(
          label: 'Main heading',
          header: true,
          child: Text(
            l10n.connectHeartsShareHope,
            style: isDesktop
                ? DesignSystem.displayLarge(context).copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    letterSpacing: -1,
                  )
                : DesignSystem.displayMedium(context).copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
            textAlign: isDesktop ? TextAlign.start : TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOut)
              .slideX(begin: -0.1, end: 0, curve: Curves.easeOut),
        ),

        const SizedBox(height: DesignSystem.spaceXL),

        // Description
        Text(
          l10n.landingHeroDescription,
          style: DesignSystem.bodyLarge(context).copyWith(
            color: DesignSystem.textSecondary,
            height: 1.7,
            fontSize: isDesktop ? 18 : 16,
          ),
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
        )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

        const SizedBox(height: DesignSystem.spaceXXL),

        // CTA Buttons
        if (isDesktop)
          Row(
            children: [
              Expanded(
                child: WebButton(
                  text: l10n.startDonating,
                  icon: Icons.favorite,
                  variant: WebButtonVariant.primary,
                  size: WebButtonSize.large,
                  fullWidth: true,
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                ),
              ),
              const SizedBox(width: DesignSystem.spaceM),
              Expanded(
                child: WebButton(
                  text: l10n.learnMore,
                  icon: Icons.play_circle_outline,
                  variant: WebButtonVariant.outline,
                  size: WebButtonSize.large,
                  fullWidth: true,
                  onPressed: _scrollToHowItWorks,
                ),
              ),
            ],
          )
              .animate(delay: 400.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0)
        else
          Column(
            children: [
              WebButton(
                text: l10n.startDonating,
                icon: Icons.favorite,
                variant: WebButtonVariant.primary,
                size: WebButtonSize.large,
                fullWidth: true,
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
              const SizedBox(height: DesignSystem.spaceM),
              WebButton(
                text: l10n.learnMore,
                icon: Icons.play_circle_outline,
                variant: WebButtonVariant.outline,
                size: WebButtonSize.large,
                fullWidth: true,
                onPressed: _scrollToHowItWorks,
              ),
            ],
          )
              .animate(delay: 400.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0),

        // Trust indicators
        const SizedBox(height: DesignSystem.spaceXXL),
        Row(
          mainAxisAlignment:
              isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            _buildHeroFeature(
              icon: Icons.people_outline,
              label: '1000+ Donors',
            ),
            SizedBox(
                width: isDesktop ? DesignSystem.spaceXL : DesignSystem.spaceL),
            _buildHeroFeature(
              icon: Icons.volunteer_activism_outlined,
              label: '5000+ Donations',
            ),
            SizedBox(
                width: isDesktop ? DesignSystem.spaceXL : DesignSystem.spaceL),
            _buildHeroFeature(
              icon: Icons.verified_user_outlined,
              label: l10n.secure100,
            ),
          ],
        )
            .animate(delay: 600.ms)
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildHeroFeature({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: DesignSystem.textSecondary,
        ),
        const SizedBox(width: DesignSystem.spaceS),
        Text(
          label,
          style: DesignSystem.labelMedium(context).copyWith(
            color: DesignSystem.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroIllustration(bool isDark) {
    return Stack(
      children: [
        // Main image container
        Container(
          height: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
            boxShadow: WebTheme.elevatedShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Hero image
                Image.asset(
                  'web/assets/images/hero/hero-hands.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback gradient
                    return Container(
                      decoration: BoxDecoration(
                        gradient: DesignSystem.heroGradient,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.volunteer_activism_outlined,
                          size: 200,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    );
                  },
                ),
                // Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 800.ms, delay: 300.ms)
            .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOut),

        // Floating stat card - Top Left
        Positioned(
          top: 20,
          left: 20,
          child: WebCard(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceL,
              vertical: DesignSystem.spaceM,
            ),
            backgroundColor: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignSystem.spaceS),
                  decoration: BoxDecoration(
                    color: DesignSystem.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: DesignSystem.error,
                    size: 20,
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceS),
                Text(
                  '8 donations today',
                  style: DesignSystem.labelLarge(context).copyWith(
                    color: DesignSystem.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
              .animate(delay: 800.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, end: 0),
        ),

        // Floating stat card - Bottom Right
        Positioned(
          bottom: 20,
          right: 20,
          child: WebCard(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceL,
              vertical: DesignSystem.spaceM,
            ),
            backgroundColor: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(DesignSystem.spaceS),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  ),
                  child: Icon(
                    Icons.people_outline,
                    color: DesignSystem.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: DesignSystem.spaceS),
                Text(
                  '67 people helped',
                  style: DesignSystem.labelLarge(context).copyWith(
                    color: DesignSystem.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
              .animate(delay: 1000.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
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
        'color': DesignSystem.primaryBlue,
        'badge': l10n.popularBadge,
        'badgeColor': DesignSystem.error,
      },
      {
        'icon': Icons.search_outlined,
        'title': l10n.smartMatching,
        'description': l10n.smartMatchingDesc,
        'color': const Color(0xFF8B5CF6), // Purple
        'badge': l10n.aiPoweredBadge,
        'badgeColor': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': l10n.verifiedUsers,
        'description': l10n.verifiedUsersDesc,
        'color': const Color(0xFF06B6D4), // Cyan
        'badge': l10n.verifiedBadge,
        'badgeColor': const Color(0xFF06B6D4),
      },
      {
        'icon': Icons.analytics_outlined,
        'title': l10n.impactTracking,
        'description': l10n.impactTrackingDesc,
        'color': DesignSystem.secondaryGreen,
        'badge': l10n.realtimeBadge,
        'badgeColor': DesignSystem.secondaryGreen,
      },
      {
        'icon': Icons.security_outlined,
        'title': l10n.securePlatform,
        'description': l10n.securePlatformDesc,
        'color': const Color(0xFFF59E0B), // Orange
        'badge': l10n.secureBadge,
        'badgeColor': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': l10n.support247,
        'description': l10n.support247Desc,
        'color': const Color(0xFF6366F1), // Indigo
        'badge': l10n.newBadge,
        'badgeColor': const Color(0xFF6366F1),
      },
    ];

    return WebTheme.section(
      child: Column(
        children: [
          // Section header with modern typography
          Semantics(
            label: 'Section heading',
            header: true,
            child: Text(
              l10n.whyChooseGivingBridge,
              style: isDesktop
                  ? DesignSystem.headlineLarge(context).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 48,
                      letterSpacing: -0.5,
                    )
                  : DesignSystem.headlineMedium(context).copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideY(begin: -0.2, end: 0),
          ),

          SizedBox(height: DesignSystem.spaceM),

          SizedBox(
            width: isDesktop ? 600 : null,
            child: Text(
              l10n.platformDescription,
              style: DesignSystem.bodyLarge(context).copyWith(
                fontSize: isDesktop ? 18 : 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),

          SizedBox(
              height:
                  isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceXXL),

          // Features grid with staggered animations
          if (isDesktop)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: DesignSystem.spaceL,
                mainAxisSpacing: DesignSystem.spaceL,
                childAspectRatio: 0.95,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final feature = features[index];
                return _buildFeatureCard(feature, theme, isDark, index);
              },
            )
          else
            Column(
              children: features.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: DesignSystem.spaceL),
                  child:
                      _buildFeatureCard(entry.value, theme, isDark, entry.key),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      Map<String, dynamic> feature, ThemeData theme, bool isDark, int index) {
    return WebCard(
      padding: EdgeInsets.all(DesignSystem.spaceXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon and badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: feature['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                  border: Border.all(
                    color: feature['color'].withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  feature['icon'],
                  size: 28,
                  color: feature['color'],
                ),
              ),
              // Badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSystem.spaceM,
                  vertical: DesignSystem.spaceXS,
                ),
                decoration: BoxDecoration(
                  color: feature['badgeColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                  border: Border.all(
                    color: feature['badgeColor'].withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  feature['badge'],
                  style: TextStyle(
                    color: feature['badgeColor'],
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: DesignSystem.spaceL),

          // Title
          Text(
            feature['title'],
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),

          SizedBox(height: DesignSystem.spaceM),

          // Description
          Expanded(
            child: Text(
              feature['description'],
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.6,
              ),
            ),
          ),

          SizedBox(height: DesignSystem.spaceM),

          // Decorative accent
          Container(
            width: 32,
            height: 3,
            decoration: BoxDecoration(
              color: feature['color'],
              borderRadius: BorderRadius.circular(DesignSystem.radiusS),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 300 + (index * 100)))
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut);
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
        'color': DesignSystem.primaryBlue,
      },
      {
        'number': '2',
        'title': l10n.stepBrowseOrPost,
        'description': l10n.stepBrowseOrPostDesc,
        'icon': Icons.inventory_outlined,
        'color': const Color(0xFF8B5CF6), // Purple
      },
      {
        'number': '3',
        'title': l10n.stepConnect,
        'description': l10n.stepConnectDesc,
        'icon': Icons.connect_without_contact_outlined,
        'color': DesignSystem.secondaryGreen,
      },
    ];

    return Container(
      key: _howItWorksKey,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceL,
        vertical: isDesktop ? 120 : 64,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark ? DesignSystem.neutral900 : DesignSystem.neutral50)
                .withOpacity(0.3),
            (isDark ? DesignSystem.neutral900 : Colors.white).withOpacity(0.5),
          ],
        ),
      ),
      child: WebTheme.section(
        child: Column(
          children: [
            // Section header
            Text(
              l10n.howItWorks,
              style: isDesktop
                  ? DesignSystem.headlineLarge(context).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 48,
                      letterSpacing: -0.5,
                    )
                  : DesignSystem.headlineMedium(context).copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideY(begin: -0.2, end: 0),

            SizedBox(height: DesignSystem.spaceM),

            Text(
              l10n.simpleSteps,
              style: DesignSystem.bodyLarge(context).copyWith(
                fontSize: isDesktop ? 18 : 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),

            SizedBox(
                height:
                    isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceXXL),

            // Steps
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.asMap().entries.map((entry) {
                  return Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: DesignSystem.spaceM),
                      child:
                          _buildStepCard(entry.value, theme, isDark, entry.key),
                    ),
                  );
                }).toList(),
              )
            else
              Column(
                children: steps.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: DesignSystem.spaceL),
                    child:
                        _buildStepCard(entry.value, theme, isDark, entry.key),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(
      Map<String, dynamic> step, ThemeData theme, bool isDark, int index) {
    final color = step['color'] as Color;

    return WebCard(
      padding: EdgeInsets.all(DesignSystem.spaceXXL),
      backgroundColor: color.withOpacity(0.03),
      child: Column(
        children: [
          // Number badge with icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  step['icon'],
                  size: 36,
                  color: color,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        step['number'],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: DesignSystem.spaceXL),

          // Title
          Text(
            step['title'],
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: DesignSystem.spaceM),

          // Description
          Text(
            step['description'],
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 400 + (index * 200)))
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut)
        .then(delay: 200.ms)
        .shimmer(duration: 800.ms, color: color.withOpacity(0.3));
  }

  Widget _buildStatsSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;
    final stats = [
      {
        'number': '10,000+',
        'label': l10n.itemsDonated,
        'icon': Icons.volunteer_activism,
        'color': DesignSystem.primaryBlue,
      },
      {
        'number': '5,000+',
        'label': l10n.happyRecipients,
        'icon': Icons.sentiment_very_satisfied,
        'color': DesignSystem.secondaryGreen,
      },
      {
        'number': '50+',
        'label': l10n.citiesCovered,
        'icon': Icons.location_city,
        'color': const Color(0xFF8B5CF6),
      },
      {
        'number': '95%',
        'label': l10n.successRate,
        'icon': Icons.verified,
        'color': const Color(0xFFF59E0B),
      },
    ];

    return WebTheme.section(
      child: Column(
        children: [
          Text(
            l10n.ourImpactInNumbers,
            style: isDesktop
                ? DesignSystem.headlineLarge(context).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 48,
                    letterSpacing: -0.5,
                  )
                : DesignSystem.headlineMedium(context).copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOut)
              .slideY(begin: -0.2, end: 0),
          SizedBox(
              height:
                  isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceXXL),
          if (isDesktop)
            Row(
              children: stats.asMap().entries.map((entry) {
                return Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: DesignSystem.spaceM),
                    child:
                        _buildStatsDisplayCard(entry.value, theme, entry.key),
                  ),
                );
              }).toList(),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: DesignSystem.spaceM,
                mainAxisSpacing: DesignSystem.spaceM,
                childAspectRatio: 1.3,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                return _buildStatsDisplayCard(stats[index], theme, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatsDisplayCard(
      Map<String, dynamic> stat, ThemeData theme, int index) {
    final color = stat['color'] as Color;

    return WebCard(
      padding: EdgeInsets.all(DesignSystem.spaceXL),
      backgroundColor: color.withOpacity(0.03),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              stat['icon'],
              size: 24,
              color: color,
            ),
          ),

          SizedBox(height: DesignSystem.spaceL),

          // Number
          Text(
            stat['number']!,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 40,
              color: color,
              letterSpacing: -1,
            ),
          ),

          SizedBox(height: DesignSystem.spaceS),

          // Label
          Text(
            stat['label']!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 200 + (index * 100)))
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut)
        .then(delay: 100.ms)
        .shimmer(duration: 1000.ms, color: color.withOpacity(0.2));
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
        'color': DesignSystem.primaryBlue,
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
        'color': DesignSystem.secondaryGreen,
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceL,
        vertical: isDesktop ? 120 : 64,
      ),
      decoration: BoxDecoration(
        color: (isDark ? DesignSystem.neutral900 : DesignSystem.neutral50)
            .withOpacity(0.3),
      ),
      child: WebTheme.section(
        child: Column(
          children: [
            Text(
              l10n.whatCommunitySays,
              style: isDesktop
                  ? DesignSystem.headlineLarge(context).copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 48,
                      letterSpacing: -0.5,
                    )
                  : DesignSystem.headlineMedium(context).copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideY(begin: -0.2, end: 0),
            SizedBox(height: DesignSystem.spaceM),
            Text(
              l10n.realStories,
              style: DesignSystem.bodyLarge(context).copyWith(
                fontSize: isDesktop ? 18 : 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            SizedBox(
                height:
                    isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceXXL),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: testimonials.asMap().entries.map((entry) {
                  return Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: DesignSystem.spaceM),
                      child: _buildTestimonialCard(
                          entry.value, theme, isDark, entry.key),
                    ),
                  );
                }).toList(),
              )
            else
              Column(
                children: testimonials.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: DesignSystem.spaceL),
                    child: _buildTestimonialCard(
                        entry.value, theme, isDark, entry.key),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial,
      ThemeData theme, bool isDark, int index) {
    final color = testimonial['color'] as Color;

    return WebCard(
      padding: EdgeInsets.all(DesignSystem.spaceXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar and info
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 12,
                      offset: Offset(0, 4),
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
                      return Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            testimonial['name'].substring(0, 1),
                            style: TextStyle(
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
              SizedBox(width: DesignSystem.spaceM),
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
                    SizedBox(height: 4),
                    Text(
                      testimonial['role'],
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: DesignSystem.spaceL),

          // Rating stars
          Row(
            children: List.generate(
              testimonial['rating'] as int,
              (index) => Icon(
                Icons.star,
                size: 18,
                color: Color(0xFFFBBF24),
              ),
            ),
          ),

          SizedBox(height: DesignSystem.spaceL),

          // Quote icon
          Container(
            padding: EdgeInsets.all(DesignSystem.spaceS),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            child: Icon(
              Icons.format_quote,
              color: color,
              size: 20,
            ),
          ),

          SizedBox(height: DesignSystem.spaceM),

          // Testimonial text
          Text(
            testimonial['text'],
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 300 + (index * 150)))
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut);
  }

  Widget _buildCTASection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceL,
        vertical: isDesktop ? 80 : 48,
      ),
      child: WebTheme.section(
        child: Container(
          padding: EdgeInsets.all(
            isDesktop
                ? DesignSystem.spaceXXXL + DesignSystem.spaceL
                : DesignSystem.spaceXXL,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DesignSystem.primaryBlue,
                Color(0xFF8B5CF6), // Purple
                DesignSystem.secondaryGreen,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
            boxShadow: [
              BoxShadow(
                color: DesignSystem.primaryBlue.withOpacity(0.3),
                blurRadius: 30,
                offset: Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                l10n.readyToMakeADifference,
                style: isDesktop
                    ? DesignSystem.headlineMedium(context).copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontSize: 40,
                      )
                    : DesignSystem.headlineSmall(context).copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
              SizedBox(height: DesignSystem.spaceM),
              Text(
                l10n.joinThousands,
                style: DesignSystem.bodyLarge(context).copyWith(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: isDesktop ? 18 : 16,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2, end: 0),
              SizedBox(height: DesignSystem.spaceXXL),
              if (isDesktop)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Primary CTA with white background
                    _buildCTAButton(
                      context,
                      text: l10n.startDonating,
                      icon: Icons.favorite,
                      backgroundColor: Colors.white,
                      textColor: DesignSystem.primaryBlue,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                    ),
                    SizedBox(width: DesignSystem.spaceL),
                    // Secondary CTA with outline
                    _buildCTAButton(
                      context,
                      text: l10n.browseDonationsAction,
                      icon: Icons.explore,
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                      borderColor: Colors.white,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                    ),
                  ],
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0)
              else
                Column(
                  children: [
                    _buildCTAButton(
                      context,
                      text: l10n.startDonating,
                      icon: Icons.favorite,
                      backgroundColor: Colors.white,
                      textColor: DesignSystem.primaryBlue,
                      fullWidth: true,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                    ),
                    SizedBox(height: DesignSystem.spaceM),
                    _buildCTAButton(
                      context,
                      text: l10n.browseDonationsAction,
                      icon: Icons.explore,
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                      borderColor: Colors.white,
                      fullWidth: true,
                      onPressed: () =>
                          Navigator.pushNamed(context, '/register'),
                    ),
                  ],
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTAButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    bool fullWidth = false,
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: WebTheme.hoverDuration,
        curve: WebTheme.webCurve,
        width: fullWidth ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: DesignSystem.spaceXXL,
          vertical: DesignSystem.spaceL,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 2)
              : null,
          boxShadow: backgroundColor != Colors.transparent
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
          child: Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: textColor,
              ),
              SizedBox(width: DesignSystem.spaceS),
              Text(
                text,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
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
        'color': DesignSystem.primaryBlue,
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
        'color': DesignSystem.secondaryGreen,
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

    return WebTheme.section(
      child: Column(
        children: [
          Text(
            l10n.featuredDonations,
            style: isDesktop
                ? DesignSystem.headlineLarge(context).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 48,
                    letterSpacing: -0.5,
                  )
                : DesignSystem.headlineMedium(context).copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOut)
              .slideY(begin: -0.2, end: 0),

          SizedBox(height: DesignSystem.spaceM),

          SizedBox(
            width: isDesktop ? 600 : null,
            child: Text(
              l10n.featuredDonationsDesc,
              style: DesignSystem.bodyLarge(context).copyWith(
                fontSize: isDesktop ? 18 : 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.2, end: 0),

          SizedBox(
              height:
                  isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceXXL),

          if (isDesktop)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: DesignSystem.spaceL,
                mainAxisSpacing: DesignSystem.spaceL,
                childAspectRatio: 0.75,
              ),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                return _buildDonationCard(
                    donations[index], theme, isDark, l10n, index);
              },
            )
          else
            Column(
              children: donations.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: DesignSystem.spaceL),
                  child: _buildDonationCard(
                      entry.value, theme, isDark, l10n, entry.key),
                );
              }).toList(),
            ),

          SizedBox(height: DesignSystem.spaceXXL),

          // Call to Action Button
          WebButton(
            text: l10n.viewAllDonations,
            icon: Icons.arrow_forward,
            variant: WebButtonVariant.outline,
            size: WebButtonSize.large,
            onPressed: () => Navigator.pushNamed(context, '/login'),
          )
              .animate(delay: 600.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildDonationCard(Map<String, dynamic> donation, ThemeData theme,
      bool isDark, AppLocalizations l10n, int index) {
    final color = donation['color'] as Color;

    // Get initials from donor name for avatar
    String getInitials(String name) {
      List<String> names = name.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }

    return WebCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image/Icon Section with gradient
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(DesignSystem.radiusL),
                topRight: Radius.circular(DesignSystem.radiusL),
              ),
            ),
            child: Stack(
              children: [
                // Icon
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      donation['image'],
                      size: 36,
                      color: color,
                    ),
                  ),
                ),
                // New Badge
                if (donation['isNew'])
                  Positioned(
                    top: DesignSystem.spaceM,
                    right: DesignSystem.spaceM,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSystem.spaceM,
                        vertical: DesignSystem.spaceS,
                      ),
                      decoration: BoxDecoration(
                        color: DesignSystem.secondaryGreen,
                        borderRadius:
                            BorderRadius.circular(DesignSystem.radiusS),
                        boxShadow: [
                          BoxShadow(
                            color: DesignSystem.secondaryGreen.withOpacity(0.4),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fiber_new,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            l10n.newLabel,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(DesignSystem.spaceL),
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
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: DesignSystem.spaceM),

                      // Category & Condition Tags
                      Wrap(
                        spacing: DesignSystem.spaceS,
                        runSpacing: DesignSystem.spaceS,
                        children: [
                          // Category
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: DesignSystem.spaceM,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(DesignSystem.radiusS),
                              border: Border.all(
                                color: color.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  donation['image'],
                                  size: 10,
                                  color: color,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  donation['category'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Condition
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: DesignSystem.spaceM,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: DesignSystem.neutral100,
                              borderRadius:
                                  BorderRadius.circular(DesignSystem.radiusS),
                            ),
                            child: Text(
                              donation['condition'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Donor Info
                  Container(
                    padding: EdgeInsets.all(DesignSystem.spaceM),
                    decoration: BoxDecoration(
                      color: DesignSystem.neutral50,
                      borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    ),
                    child: Row(
                      children: [
                        // Donor Avatar
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              getInitials(donation['donorName']),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: DesignSystem.spaceM),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                donation['donorName'],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 10,
                                    color: DesignSystem.textSecondary,
                                  ),
                                  SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      donation['location'],
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
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
    )
        .animate(delay: Duration(milliseconds: 200 + (index * 100)))
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut);
  }

  Widget _buildFooter(BuildContext context, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceL,
        vertical: isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceXXL,
      ),
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.neutral900 : DesignSystem.neutral50,
        border: Border(
          top: BorderSide(
            color: DesignSystem.getBorderColor(context),
            width: 1,
          ),
        ),
      ),
      child: WebTheme.section(
        child: Column(
          children: [
            // Logo and Title
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        DesignSystem.primaryBlue,
                        DesignSystem.primaryBlueDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: DesignSystem.primaryBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: DesignSystem.spaceM),
                Text(
                  l10n.appTitle,
                  style: DesignSystem.titleLarge(context).copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),

            SizedBox(height: DesignSystem.spaceL),

            // Tagline
            Text(
              l10n.madeWithLove,
              style: DesignSystem.bodyMedium(context).copyWith(
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 200.ms).fadeIn(duration: 600.ms),

            SizedBox(height: DesignSystem.spaceM),

            // Copyright
            Text(
              l10n.copyright,
              style: DesignSystem.bodySmall(context).copyWith(
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ).animate(delay: 400.ms).fadeIn(duration: 600.ms),
          ],
        ),
      ),
    );
  }
}

// Custom painter for dot pattern background
