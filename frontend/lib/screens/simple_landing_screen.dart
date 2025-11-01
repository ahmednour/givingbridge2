import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/locale_provider.dart';

class SimpleLandingScreen extends StatelessWidget {
  const SimpleLandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 768;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Directionality(
      textDirection: localeProvider.textDirection,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
          children: [
            // Header
            _buildHeader(context, isDesktop),
            
            // Hero Section
            _buildHeroSection(context, theme, isDesktop),
            
            // Features Section
            _buildFeaturesSection(context, theme, isDesktop),
            
            // CTA Section
            _buildCTASection(context, theme, isDesktop),
            
            // Footer
            _buildFooter(context, theme),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXL,
        vertical: AppTheme.spacingM,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor,
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
                  size: 22,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                'Giving Bridge',
                style: AppTheme.headingMedium,
              ),
            ],
          ),
          
          const Spacer(),
          
          // Navigation buttons
          if (isDesktop) ...[
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Login'),
            ),
            const SizedBox(width: AppTheme.spacingM),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Get Started'),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _showMobileMenu(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ThemeData theme, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacingXXL : AppTheme.spacingL,
        vertical: isDesktop ? 120 : 80,
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
      child: Column(
        children: [
          // Main headline
          Text(
            'Connect Hearts, Share Hope',
            style: isDesktop
                ? AppTheme.headingLarge.copyWith(fontSize: 48)
                : AppTheme.headingLarge,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Description
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Join our community of generous donors and those in need. Make a difference with every donation, create lasting connections, and build a better world together.',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondaryColor,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXXL),
          
          // CTA Buttons
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXL,
                      vertical: AppTheme.spacingL,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite),
                      SizedBox(width: AppTheme.spacingS),
                      Text('Start Donating'),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                OutlinedButton(
                  onPressed: () {
                    // Scroll to features section
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingXL,
                      vertical: AppTheme.spacingL,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline),
                      SizedBox(width: AppTheme.spacingS),
                      Text('Learn More'),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingL,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite),
                        SizedBox(width: AppTheme.spacingS),
                        Text('Start Donating'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Scroll to features section
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spacingL,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: AppTheme.spacingS),
                        Text('Learn More'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, ThemeData theme, bool isDesktop) {
    final features = [
      {
        'icon': Icons.favorite_outline,
        'title': 'Easy Donations',
        'description': 'Simple and secure donation process with just a few clicks.',
        'color': AppTheme.primaryColor,
      },
      {
        'icon': Icons.search_outlined,
        'title': 'Smart Matching',
        'description': 'Find the perfect donation requests that match your interests.',
        'color': AppTheme.secondaryColor,
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Verified Users',
        'description': 'All users are verified to ensure safe and trustworthy donations.',
        'color': AppTheme.infoColor,
      },
      {
        'icon': Icons.analytics_outlined,
        'title': 'Impact Tracking',
        'description': 'Track your donation impact and see the difference you make.',
        'color': AppTheme.warningColor,
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacingXXL : AppTheme.spacingL,
        vertical: isDesktop ? 120 : 80,
      ),
      child: Column(
        children: [
          Text(
            'Why Choose Giving Bridge?',
            style: isDesktop
                ? AppTheme.headingLarge.copyWith(fontSize: 40)
                : AppTheme.headingLarge,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Our platform makes it easy to connect donors with those in need, creating meaningful relationships and lasting impact.',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXXL),
          
          // Features grid
          if (isDesktop)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.spacingL,
                mainAxisSpacing: AppTheme.spacingL,
                childAspectRatio: 1.2,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                return _buildFeatureCard(features[index]);
              },
            )
          else
            Column(
              children: features.map((feature) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
                  child: _buildFeatureCard(feature),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (feature['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
              ),
              child: Icon(
                feature['icon'],
                size: 28,
                color: feature['color'],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            Text(
              feature['title'],
              style: AppTheme.headingSmall,
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            Text(
              feature['description'],
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondaryColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCTASection(BuildContext context, ThemeData theme, bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppTheme.spacingXXL : AppTheme.spacingL,
        vertical: isDesktop ? 120 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            AppTheme.secondaryColor.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Ready to Make a Difference?',
            style: isDesktop
                ? AppTheme.headingLarge.copyWith(fontSize: 40)
                : AppTheme.headingLarge,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppTheme.spacingM),
          
          Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Text(
              'Join thousands of users who are already making a positive impact in their communities.',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXXL),
          
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? AppTheme.spacingXXL : AppTheme.spacingXL,
                vertical: AppTheme.spacingL,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_forward),
                SizedBox(width: AppTheme.spacingS),
                Text('Get Started Today'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXL,
        vertical: AppTheme.spacingXXL,
      ),
      decoration: BoxDecoration(
        color: AppTheme.textPrimaryColor,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                'Giving Bridge',
                style: AppTheme.headingSmall.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingL),
          
          Text(
            'Connecting hearts, changing lives, one donation at a time.',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          Text(
            '© 2024 Giving Bridge. Made with ❤️ for graduation project.',
            style: AppTheme.bodySmall.copyWith(
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/login');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Register'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/register');
              },
            ),
          ],
        ),
      ),
    );
  }
}