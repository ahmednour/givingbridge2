import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_input.dart';
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
    if (value.length < 6) {
      return l10n.passwordTooShort;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.all(AppTheme.spacingL),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                  side: const BorderSide(color: AppTheme.borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXXL),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusXL),
                              ),
                              child: const Icon(
                                Icons.favorite_outline,
                                color: AppTheme.primaryColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingL),
                            Text(
                              l10n.welcomeBack,
                              style: AppTheme.headingLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            Text(
                              '${l10n.signIn} to your ${l10n.appTitle} account',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spacingXL),

                        // Error message
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            decoration: BoxDecoration(
                              color: AppTheme.errorColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusM),
                              border: Border.all(
                                color: AppTheme.errorColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppTheme.errorColor,
                                  size: 20,
                                ),
                                const SizedBox(width: AppTheme.spacingS),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.errorColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingL),
                        ],

                        // Form fields
                        AppInput(
                          label: l10n.email,
                          hint: 'Enter your ${l10n.email.toLowerCase()}',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: AppTheme.textSecondaryColor,
                            size: 20,
                          ),
                          validator: _validateEmail,
                        ),

                        const SizedBox(height: AppTheme.spacingL),

                        AppInput(
                          label: l10n.password,
                          hint: 'Enter your ${l10n.password.toLowerCase()}',
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: AppTheme.textSecondaryColor,
                            size: 20,
                          ),
                          validator: _validatePassword,
                          onSubmitted: (_) => _handleLogin(),
                        ),

                        const SizedBox(height: AppTheme.spacingXL),

                        // Login button
                        AppButton(
                          text: l10n.signIn,
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                          size: ButtonSize.large,
                          width: double.infinity,
                        ),

                        const SizedBox(height: AppTheme.spacingL),

                        // Quick login buttons for testing
                        Wrap(
                          spacing: AppTheme.spacingS,
                          runSpacing: AppTheme.spacingS,
                          children: [
                            AppButton(
                              text: 'Demo Donor',
                              onPressed: () {
                                _emailController.text = 'demo@example.com';
                                _passwordController.text = 'demo123';
                                _handleLogin();
                              },
                              variant: ButtonVariant.outline,
                              size: ButtonSize.small,
                            ),
                            AppButton(
                              text: 'Demo Admin',
                              onPressed: () {
                                _emailController.text =
                                    'admin@givingbridge.com';
                                _passwordController.text = 'admin123';
                                _handleLogin();
                              },
                              variant: ButtonVariant.outline,
                              size: ButtonSize.small,
                            ),
                            AppButton(
                              text: 'Demo Receiver',
                              onPressed: () {
                                _emailController.text = 'receiver@example.com';
                                _passwordController.text = 'receive123';
                                _handleLogin();
                              },
                              variant: ButtonVariant.outline,
                              size: ButtonSize.small,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spacingXL),

                        // Register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${l10n.dontHaveAccount} ",
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: _navigateToRegister,
                              child: Text(
                                l10n.signUp,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LanguageButton(
                        label: 'EN',
                        isSelected: localeProvider.isEnglish,
                        onTap: () =>
                            localeProvider.setLocale(const Locale('en')),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: AppTheme.borderColor,
                      ),
                      _LanguageButton(
                        label: 'عربي',
                        isSelected: localeProvider.isArabic,
                        onTap: () =>
                            localeProvider.setLocale(const Locale('ar')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
