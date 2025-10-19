import 'package:flutter/material.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/gb_text_field.dart';
import '../widgets/common/gb_card.dart';
import '../widgets/common/gb_empty_state.dart';

/// Component Showcase Screen
/// Demo screen to showcase all new enhanced components
/// USE THIS FOR TESTING AND DEMONSTRATION
class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({Key? key}) : super(key: key);

  @override
  State<ComponentShowcaseScreen> createState() =>
      _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Component Showcase'),
        backgroundColor: DesignSystem.getSurfaceColor(context),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          DesignSystem.getResponsivePadding(MediaQuery.of(context).size.width),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buttons Section
            _buildSection(
              title: 'Buttons',
              children: [
                Wrap(
                  spacing: DesignSystem.spaceM,
                  runSpacing: DesignSystem.spaceM,
                  children: [
                    GBPrimaryButton(
                      text: 'Primary Button',
                      onPressed: () => _showSnackBar('Primary pressed'),
                      leftIcon: const Icon(Icons.favorite),
                    ),
                    GBSecondaryButton(
                      text: 'Secondary Button',
                      onPressed: () => _showSnackBar('Secondary pressed'),
                      leftIcon: const Icon(Icons.eco),
                    ),
                    GBOutlineButton(
                      text: 'Outline Button',
                      onPressed: () => _showSnackBar('Outline pressed'),
                      leftIcon: const Icon(Icons.info_outline),
                    ),
                    GBButton(
                      text: 'Loading Button',
                      variant: GBButtonVariant.primary,
                      isLoading: _isLoading,
                      onPressed: _toggleLoading,
                    ),
                    GBButton(
                      text: 'Disabled Button',
                      variant: GBButtonVariant.primary,
                      isDisabled: true,
                      onPressed: () {},
                    ),
                    GBButton(
                      text: 'Danger Button',
                      variant: GBButtonVariant.danger,
                      onPressed: () => _showSnackBar('Danger pressed'),
                      leftIcon: const Icon(Icons.delete),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSystem.spaceL),
                Text(
                  'Button Sizes',
                  style: DesignSystem.titleSmall(context),
                ),
                const SizedBox(height: DesignSystem.spaceM),
                Wrap(
                  spacing: DesignSystem.spaceM,
                  runSpacing: DesignSystem.spaceM,
                  children: [
                    GBPrimaryButton(
                      text: 'Small',
                      size: GBButtonSize.small,
                      onPressed: () {},
                    ),
                    GBPrimaryButton(
                      text: 'Medium',
                      size: GBButtonSize.medium,
                      onPressed: () {},
                    ),
                    GBPrimaryButton(
                      text: 'Large',
                      size: GBButtonSize.large,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: DesignSystem.spaceL),
                GBPrimaryButton(
                  text: 'Full Width Button',
                  fullWidth: true,
                  onPressed: () {},
                  leftIcon: const Icon(Icons.send),
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spaceXXL),

            // Text Fields Section
            _buildSection(
              title: 'Text Fields',
              children: [
                GBTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  helperText: 'We\'ll never share your email',
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (!value.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                const SizedBox(height: DesignSystem.spaceL),
                GBTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true, // Auto password toggle!
                  prefixIcon: const Icon(Icons.lock_outline),
                  helperText: 'Minimum 8 characters',
                ),
                if (_passwordController.text.isNotEmpty)
                  PasswordStrengthMeter(password: _passwordController.text),
                const SizedBox(height: DesignSystem.spaceL),
                GBTextField(
                  label: 'Message',
                  hint: 'Write a message...',
                  controller: _messageController,
                  maxLines: 4,
                  maxLength: 500,
                  showCounter: true,
                  helperText: 'Tell us what you need',
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spaceXXL),

            // Cards Section
            _buildSection(
              title: 'Cards',
              children: [
                GBCard(
                  elevation: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Card',
                        style: DesignSystem.titleMedium(context),
                      ),
                      const SizedBox(height: DesignSystem.spaceS),
                      Text(
                        'This is a basic card with elevation and border.',
                        style: DesignSystem.bodyMedium(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceL),
                GBCard(
                  gradient: DesignSystem.primaryGradient,
                  showBorder: false,
                  onTap: () => _showSnackBar('Card tapped'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gradient Card',
                        style: DesignSystem.titleMedium(context).copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: DesignSystem.spaceS),
                      Text(
                        'This card has a gradient background and is clickable.',
                        style: DesignSystem.bodyMedium(context).copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spaceXXL),

            // Stat Cards Section
            _buildSection(
              title: 'Stat Cards',
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > DesignSystem.tablet) {
                      return Row(
                        children: [
                          Expanded(
                            child: GBStatCard(
                              title: 'Total Donations',
                              value: '847',
                              icon: Icons.favorite,
                              color: DesignSystem.accentPink,
                              showCountUp: true,
                              trend: '+12%',
                            ),
                          ),
                          const SizedBox(width: DesignSystem.spaceL),
                          Expanded(
                            child: GBStatCard(
                              title: 'Active Users',
                              value: '234',
                              icon: Icons.people,
                              color: DesignSystem.primaryBlue,
                              showCountUp: true,
                              trend: '+8%',
                            ),
                          ),
                          const SizedBox(width: DesignSystem.spaceL),
                          Expanded(
                            child: GBStatCard(
                              title: 'Success Rate',
                              value: '94%',
                              icon: Icons.check_circle,
                              color: DesignSystem.success,
                              showCountUp: true,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          GBStatCard(
                            title: 'Total Donations',
                            value: '847',
                            icon: Icons.favorite,
                            color: DesignSystem.accentPink,
                            showCountUp: true,
                            trend: '+12%',
                          ),
                          const SizedBox(height: DesignSystem.spaceL),
                          GBStatCard(
                            title: 'Active Users',
                            value: '234',
                            icon: Icons.people,
                            color: DesignSystem.primaryBlue,
                            showCountUp: true,
                            trend: '+8%',
                          ),
                          const SizedBox(height: DesignSystem.spaceL),
                          GBStatCard(
                            title: 'Success Rate',
                            value: '94%',
                            icon: Icons.check_circle,
                            color: DesignSystem.success,
                            showCountUp: true,
                          ),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spaceXXL),

            // Donation Card Section
            _buildSection(
              title: 'Donation Card',
              children: [
                GBDonationCard(
                  title: 'Winter Clothes for Children',
                  description:
                      'Gently used winter jackets, sweaters, and boots suitable for kids aged 5-10 years.',
                  category: 'Clothes',
                  status: 'Available',
                  donorName: 'Sarah Johnson',
                  location: 'New York, NY',
                  categoryIcon: Icons.checkroom,
                  onMessage: () => _showSnackBar('Message donor'),
                  onRequest: () => _showSnackBar('Request donation'),
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spaceXXL),

            // Empty States Section
            _buildSection(
              title: 'Empty States',
              children: [
                GBCard(
                  child: SizedBox(
                    height: 400,
                    child: GBEmptyState.noDonations(
                      onCreate: () => _showSnackBar('Create donation'),
                    ),
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceL),
                GBCard(
                  child: SizedBox(
                    height: 400,
                    child: GBEmptyState.noSearchResults(),
                  ),
                ),
                const SizedBox(height: DesignSystem.spaceL),
                GBCard(
                  child: SizedBox(
                    height: 400,
                    child: GBEmptyState.error(
                      onRetry: () => _showSnackBar('Retrying...'),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spaceXXL),

            // Loading States Section
            _buildSection(
              title: 'Loading States',
              children: [
                const GBSkeletonCard(),
                const SizedBox(height: DesignSystem.spaceL),
                Row(
                  children: const [
                    GBSkeletonLoader(width: 100, height: 100),
                    SizedBox(width: DesignSystem.spaceL),
                    Expanded(
                      child: Column(
                        children: [
                          GBSkeletonLoader(width: double.infinity, height: 20),
                          SizedBox(height: DesignSystem.spaceS),
                          GBSkeletonLoader(width: 200, height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: DesignSystem.spaceXXL),

            // Design Tokens Section
            _buildSection(
              title: 'Design Tokens',
              children: [
                _buildColorPalette(),
                const SizedBox(height: DesignSystem.spaceL),
                _buildTypographyShowcase(),
                const SizedBox(height: DesignSystem.spaceL),
                _buildSpacingShowcase(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: DesignSystem.headlineSmall(context),
        ),
        const SizedBox(height: DesignSystem.spaceL),
        ...children,
      ],
    );
  }

  Widget _buildColorPalette() {
    return Wrap(
      spacing: DesignSystem.spaceM,
      runSpacing: DesignSystem.spaceM,
      children: [
        _buildColorSwatch('Primary Blue', DesignSystem.primaryBlue),
        _buildColorSwatch('Secondary Green', DesignSystem.secondaryGreen),
        _buildColorSwatch('Accent Pink', DesignSystem.accentPink),
        _buildColorSwatch('Accent Purple', DesignSystem.accentPurple),
        _buildColorSwatch('Accent Amber', DesignSystem.accentAmber),
        _buildColorSwatch('Success', DesignSystem.success),
        _buildColorSwatch('Warning', DesignSystem.warning),
        _buildColorSwatch('Error', DesignSystem.error),
      ],
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            boxShadow: DesignSystem.elevation2,
          ),
        ),
        const SizedBox(height: DesignSystem.spaceS),
        Text(
          name,
          style: DesignSystem.bodySmall(context),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTypographyShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display Large', style: DesignSystem.displayLarge(context)),
        Text('Display Medium', style: DesignSystem.displayMedium(context)),
        Text('Display Small', style: DesignSystem.displaySmall(context)),
        Text('Headline Large', style: DesignSystem.headlineLarge(context)),
        Text('Headline Medium', style: DesignSystem.headlineMedium(context)),
        Text('Headline Small', style: DesignSystem.headlineSmall(context)),
        Text('Title Large', style: DesignSystem.titleLarge(context)),
        Text('Title Medium', style: DesignSystem.titleMedium(context)),
        Text('Title Small', style: DesignSystem.titleSmall(context)),
        Text('Body Large', style: DesignSystem.bodyLarge(context)),
        Text('Body Medium', style: DesignSystem.bodyMedium(context)),
        Text('Body Small', style: DesignSystem.bodySmall(context)),
        Text('Label Large', style: DesignSystem.labelLarge(context)),
        Text('Label Medium', style: DesignSystem.labelMedium(context)),
        Text('Label Small', style: DesignSystem.labelSmall(context)),
      ],
    );
  }

  Widget _buildSpacingShowcase() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSpacingExample('XXS (2px)', DesignSystem.spaceXXS),
        _buildSpacingExample('XS (4px)', DesignSystem.spaceXS),
        _buildSpacingExample('S (8px)', DesignSystem.spaceS),
        _buildSpacingExample('M (16px)', DesignSystem.spaceM),
        _buildSpacingExample('L (24px)', DesignSystem.spaceL),
        _buildSpacingExample('XL (32px)', DesignSystem.spaceXL),
        _buildSpacingExample('XXL (48px)', DesignSystem.spaceXXL),
        _buildSpacingExample('XXXL (64px)', DesignSystem.spaceXXXL),
      ],
    );
  }

  Widget _buildSpacingExample(String label, double size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignSystem.spaceS),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: DesignSystem.bodySmall(context)),
          ),
          Container(
            width: size,
            height: 20,
            color: DesignSystem.primaryBlue,
          ),
        ],
      ),
    );
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: DesignSystem.primaryBlue,
      ),
    );
  }
}
