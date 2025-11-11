import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/design_system.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/common/gb_text_field.dart';
import '../widgets/common/web_button.dart';
import '../widgets/common/web_card.dart';
import '../l10n/app_localizations.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      setState(() {
        _errorMessage = authProvider.errorMessage;
      });
    }
  }

  void _navigateToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  String? _validateEmail(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.requiredField;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return l10n.invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.requiredField;
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor:
          isDark ? DesignSystem.neutral900 : DesignSystem.neutral50,
      body: Stack(
        children: [
          // Split-screen layout for desktop
          if (isDesktop)
            Row(
              children: [
                // Left side - Branding
                _buildBrandingSection(context, l10n, isDark),
                // Right side - Login form
                Expanded(
                  child: _buildLoginForm(context, l10n, isDark, isDesktop),
                ),
              ],
            )
          else
            _buildLoginForm(context, l10n, isDark, isDesktop),

          // Language switcher
          _buildLanguageSwitcher(localeProvider, isDark),
        ],
      ),
    );
  }

  Widget _buildBrandingSection(
      BuildContext context, AppLocalizations l10n, bool isDark) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              DesignSystem.primaryBlue,
              DesignSystem.primaryBlueDark,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(DesignSystem.spaceXXXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 64,
                    color: Colors.white,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),

                SizedBox(height: DesignSystem.spaceXXL),

                // Title
                Text(
                  l10n.appTitle,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                SizedBox(height: DesignSystem.spaceL),

                // Tagline
                Text(
                  'Connect Hearts, Share Hope',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),

                SizedBox(height: DesignSystem.spaceXXXL),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStat('10,000+', 'Donations'),
                    SizedBox(width: DesignSystem.spaceXXL),
                    _buildStat('5,000+', 'Users'),
                    SizedBox(width: DesignSystem.spaceXXXL),
                    _buildStat('50+', 'Cities'),
                  ],
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        SizedBox(height: DesignSystem.spaceS),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context, AppLocalizations l10n,
      bool isDark, bool isDesktop) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 480),
        margin: EdgeInsets.all(
            isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceL),
        child: SingleChildScrollView(
          child: WebCard(
            padding: EdgeInsets.all(
                isDesktop ? DesignSystem.spaceXXXL : DesignSystem.spaceXXL),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Column(
                    children: [
                      if (!isDesktop) ...[
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                DesignSystem.primaryBlue,
                                DesignSystem.primaryBlueDark,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(DesignSystem.radiusXL),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    DesignSystem.primaryBlue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite,
                            size: 36,
                            color: Colors.white,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(begin: Offset(0.8, 0.8), end: Offset(1, 1)),
                        SizedBox(height: DesignSystem.spaceL),
                      ],
                      Text(
                        l10n.welcomeBack,
                        style: isDesktop
                            ? DesignSystem.headlineLarge(context).copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 36,
                              )
                            : DesignSystem.headlineMedium(context).copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 100.ms)
                          .slideY(begin: -0.2, end: 0),
                      SizedBox(height: DesignSystem.spaceM),
                      Text(
                        '${l10n.signIn} to your ${l10n.appTitle} account',
                        style: DesignSystem.bodyLarge(context).copyWith(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 600.ms)
                          .slideY(begin: 0.2, end: 0),
                    ],
                  ),

                  SizedBox(height: DesignSystem.spaceXXL),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: EdgeInsets.all(DesignSystem.spaceM),
                      decoration: BoxDecoration(
                        color: DesignSystem.error.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(DesignSystem.radiusM),
                        border: Border.all(
                          color: DesignSystem.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: DesignSystem.error,
                            size: 20,
                          ),
                          SizedBox(width: DesignSystem.spaceS),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: DesignSystem.bodyMedium(context).copyWith(
                                color: DesignSystem.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: -0.5, end: 0),
                    SizedBox(height: DesignSystem.spaceL),
                  ],

                  // Form fields
                  GBTextField(
                    label: l10n.email,
                    hint: l10n.enterYourEmail,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      size: 20,
                    ),
                    validator: _validateEmail,
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  SizedBox(height: DesignSystem.spaceL),

                  GBTextField(
                    label: l10n.password,
                    hint: l10n.enterYourPassword,
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      size: 20,
                    ),
                    validator: _validatePassword,
                    onSubmitted: (_) => _handleLogin(),
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  SizedBox(height: DesignSystem.spaceXXL),

                  // Login button
                  WebButton(
                    text: l10n.signIn,
                    icon: Icons.login,
                    variant: WebButtonVariant.primary,
                    size: WebButtonSize.large,
                    fullWidth: true,
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),

                  SizedBox(height: DesignSystem.spaceL),

                  // Quick login buttons for testing
                  Wrap(
                    spacing: DesignSystem.spaceS,
                    runSpacing: DesignSystem.spaceS,
                    alignment: WrapAlignment.center,
                    children: [
                      WebButton(
                        text: 'Demo Donor',
                        variant: WebButtonVariant.ghost,
                        size: WebButtonSize.small,
                        onPressed: () {
                          _emailController.text = 'demo@example.com';
                          _passwordController.text = 'Demo1234';
                          _handleLogin();
                        },
                      ),
                      WebButton(
                        text: 'Demo Admin',
                        variant: WebButtonVariant.ghost,
                        size: WebButtonSize.small,
                        onPressed: () {
                          _emailController.text = 'admin@givingbridge.com';
                          _passwordController.text = 'Admin1234';
                          _handleLogin();
                        },
                      ),
                      WebButton(
                        text: 'Demo Receiver',
                        variant: WebButtonVariant.ghost,
                        size: WebButtonSize.small,
                        onPressed: () {
                          _emailController.text = 'receiver@example.com';
                          _passwordController.text = 'Receive1234';
                          _handleLogin();
                        },
                      ),
                    ],
                  ).animate(delay: 600.ms).fadeIn(duration: 600.ms),

                  SizedBox(height: DesignSystem.spaceXXL),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${l10n.dontHaveAccount} ",
                        style: DesignSystem.bodyMedium(context),
                      ),
                      GestureDetector(
                        onTap: _navigateToRegister,
                        child: Text(
                          l10n.signUp,
                          style: DesignSystem.bodyMedium(context).copyWith(
                            color: DesignSystem.primaryBlue,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ).animate(delay: 700.ms).fadeIn(duration: 600.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher(LocaleProvider localeProvider, bool isDark) {
    return Positioned(
      top: 24,
      right: 24,
      child: WebCard(
        padding: EdgeInsets.all(DesignSystem.spaceXS),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageButton(
              label: 'EN',
              isSelected: localeProvider.isEnglish,
              onTap: () => localeProvider.setLocale(Locale('en')),
            ),
            Container(
              width: 1,
              height: 30,
              color: DesignSystem.getBorderColor(context),
            ),
            _LanguageButton(
              label: 'عربي',
              isSelected: localeProvider.isArabic,
              onTap: () => localeProvider.setLocale(Locale('ar')),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms, delay: 800.ms)
          .slideX(begin: 0.3, end: 0),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS,
        ),
        child: Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.textSecondaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
