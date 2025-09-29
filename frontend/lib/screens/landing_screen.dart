import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';

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

            // Features Section
            _buildFeaturesSection(context, theme, isDark, isDesktop),

            // How It Works Section
            _buildHowItWorksSection(context, theme, isDark, isDesktop),

            // Stats Section
            _buildStatsSection(context, theme, isDark, isDesktop),

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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingM,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurfaceColor : AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
            width: 1,
          ),
        ),
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
                'Giving Bridge',
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
              GhostButton(
                text: 'Login',
                size: ButtonSize.medium,
                onPressed: () => Navigator.pushNamed(context, '/login'),
              ),
              const SizedBox(width: AppTheme.spacingS + AppTheme.spacingXS),
              PrimaryButton(
                text: 'Get Started',
                size: ButtonSize.medium,
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacingXXL + AppTheme.spacingM : AppTheme.spacingL,
        vertical: isDesktop ? AppTheme.spacingXXL + AppTheme.spacingM : AppTheme.spacingXXL,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.05),
            AppTheme.secondaryColor.withValues(alpha: 0.05),
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
                    Expanded(child: _buildHeroContent(theme, isDesktop)),
                    const SizedBox(width: AppTheme.spacingXXL + AppTheme.spacingM),
                    Expanded(child: _buildHeroIllustration(isDark)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildHeroContent(theme, isDesktop),
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

  Widget _buildHeroContent(ThemeData theme, bool isDesktop) {
    return Column(
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'Connect Hearts,\nShare Hope',
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
          textAlign: isDesktop ? TextAlign.start : TextAlign.center,
        ),
        const SizedBox(height: AppTheme.spacingL),
        Text(
          'Giving Bridge connects generous donors with those in need, creating a community where kindness flows freely and every donation makes a real difference.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
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
              PrimaryButton(
                text: 'Start Donating',
                size: ButtonSize.large,
                leftIcon: const Icon(Icons.favorite, size: 20),
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
              const SizedBox(width: AppTheme.spacingM),
              OutlineButton(
                text: 'Learn More',
                size: ButtonSize.large,
                leftIcon: const Icon(Icons.play_circle_outline, size: 20),
                onPressed: () {},
              ),
            ],
          )
        else
          Column(
            children: [
              PrimaryButton(
                text: 'Start Donating',
                size: ButtonSize.large,
                width: double.infinity,
                leftIcon: const Icon(Icons.favorite, size: 20),
                onPressed: () => Navigator.pushNamed(context, '/register'),
              ),
              const SizedBox(height: AppTheme.spacingM),
              OutlineButton(
                text: 'Learn More',
                size: ButtonSize.large,
                width: double.infinity,
                leftIcon: const Icon(Icons.play_circle_outline, size: 20),
                onPressed: () {},
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHeroIllustration(bool isDark) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: (isDark
                ? AppTheme.darkSurfaceColor
                : AppTheme.surfaceColor)
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isDark ? AppTheme.darkBorderColor : AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.volunteer_activism,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            Text(
              'Beautiful Illustration\nComing Soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTheme.darkTextSecondaryColor
                    : AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final features = [
      {
        'icon': Icons.favorite_outline,
        'title': 'Easy Donations',
        'description':
            'Simple and secure way to donate items to those who need them most.',
      },
      {
        'icon': Icons.search_outlined,
        'title': 'Smart Matching',
        'description':
            'Our platform intelligently connects donors with receivers based on location and needs.',
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Verified Users',
        'description':
            'All users are verified to ensure safe and trustworthy transactions.',
      },
      {
        'icon': Icons.analytics_outlined,
        'title': 'Impact Tracking',
        'description':
            'Track your donations and see the real impact you\'re making in your community.',
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacingXXL + AppTheme.spacingM : AppTheme.spacingL,
        vertical: AppTheme.spacingXXL + AppTheme.spacingM,
      ),
      child: Column(
        children: [
          Text(
            'Why Choose Giving Bridge?',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Our platform makes giving and receiving simple, safe, and meaningful.',
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
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.spacingXL,
                mainAxisSpacing: AppTheme.spacingXL,
                childAspectRatio: 1.2,
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
    return CustomCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              feature['icon'],
              size: 30,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM + AppTheme.spacingXS),
          Text(
            feature['title'],
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS + AppTheme.spacingXS),
          Text(
            feature['description'],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final steps = [
      {
        'number': '1',
        'title': 'Sign Up',
        'description':
            'Create your account as a donor or receiver in just a few clicks.',
        'icon': Icons.person_add_outlined,
      },
      {
        'number': '2',
        'title': 'Browse or Post',
        'description':
            'Donors post items, receivers browse available donations.',
        'icon': Icons.inventory_outlined,
      },
      {
        'number': '3',
        'title': 'Connect',
        'description': 'Get matched with verified users in your community.',
        'icon': Icons.connect_without_contact_outlined,
      },
      {
        'number': '4',
        'title': 'Share & Receive',
        'description':
            'Complete the donation and make a positive impact together.',
        'icon': Icons.celebration_outlined,
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacingXXL + AppTheme.spacingM : AppTheme.spacingL,
        vertical: AppTheme.spacingXXL + AppTheme.spacingM,
      ),
      decoration: BoxDecoration(
        color: (isDark
                ? AppTheme.darkSurfaceColor
                : AppTheme.surfaceColor)
            .withValues(alpha: 0.3),
      ),
      child: Column(
        children: [
          Text(
            'How It Works',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          if (isDesktop)
            Row(
              children: steps.map((step) {
                final index = steps.indexOf(step);
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildStepCard(step, theme, isDark)),
                      if (index < steps.length - 1)
                        Container(
                          width: 40,
                          height: 2,
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          margin: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM),
                        ),
                    ],
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
    return CustomCard(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLightColor],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                step['number'],
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingM + AppTheme.spacingXS),
          Icon(
            step['icon'],
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            step['title'],
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingS + AppTheme.spacingXS),
          Text(
            step['description'],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    final stats = [
      {'number': '10,000+', 'label': 'Items Donated'},
      {'number': '5,000+', 'label': 'Happy Recipients'},
      {'number': '50+', 'label': 'Cities Covered'},
      {'number': '95%', 'label': 'Success Rate'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacingXXL + AppTheme.spacingM : AppTheme.spacingL,
        vertical: AppTheme.spacingXXL + AppTheme.spacingM,
      ),
      child: Column(
        children: [
          Text(
            'Our Impact in Numbers',
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
                  child: _buildStatCard(stat, theme),
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
                return _buildStatCard(stats[index], theme);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(Map<String, String> stat, ThemeData theme) {
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

  Widget _buildCTASection(
      BuildContext context, ThemeData theme, bool isDark, bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacingXXL + AppTheme.spacingM : AppTheme.spacingL,
        vertical: AppTheme.spacingXXL,
      ),
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDarkColor],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Make a Difference?',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Join thousands of people who are already making their communities better, one donation at a time.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXL),
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXL,
                      vertical: AppTheme.spacingM,
                    ),
                  ),
                  child: const Text(
                    'Start Donating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                OutlineButton(
                  text: 'Browse Donations',
                  size: ButtonSize.large,
                  onPressed: () => Navigator.pushNamed(context, '/register'),
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
                    foregroundColor: AppTheme.primaryColor,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    'Start Donating',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                OutlineButton(
                  text: 'Browse Donations',
                  size: ButtonSize.large,
                  width: double.infinity,
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme, bool isDark) {
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
                'Giving Bridge',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            '© 2025 Giving Bridge. All rights reserved.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Made with ❤️ for communities worldwide',
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
