import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/design_system.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/gb_text_field.dart';
import '../widgets/common/web_button.dart';
import '../widgets/common/web_card.dart';
import '../l10n/app_localizations.dart';
import 'dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedRole = 'donor';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.nameIsRequired;
    }
    if (value.length < 2) {
      return AppLocalizations.of(context)!.nameTooShortValidation;
    }
    return null;
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
      return AppLocalizations.of(context)!.passwordTooShortValidation;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return AppLocalizations.of(context)!.passwordMustContainUppercase;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
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
                // Left side - Branding with role benefits
                _buildBrandingSection(context, l10n, isDark),
                // Right side - Registration form
                Expanded(
                  child:
                      _buildRegistrationForm(context, l10n, isDark, isDesktop),
                ),
              ],
            )
          else
            _buildRegistrationForm(context, l10n, isDark, isDesktop),

          // Back button overlay
          _buildBackButton(context, isDark),
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
              DesignSystem.secondaryGreen,
              DesignSystem.secondaryGreenDark,
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
                  'Join ${l10n.appTitle}',
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
                  AppLocalizations.of(context)!.makeDifferenceToday,
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

                // Benefits
                Column(
                  children: [
                    _buildBenefit(Icons.verified_user,
                        AppLocalizations.of(context)!.verifiedPlatform),
                    SizedBox(height: DesignSystem.spaceL),
                    _buildBenefit(Icons.handshake,
                        AppLocalizations.of(context)!.directImpact),
                    SizedBox(height: DesignSystem.spaceL),
                    _buildBenefit(Icons.security,
                        AppLocalizations.of(context)!.securePrivate),
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

  Widget _buildBenefit(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(DesignSystem.spaceS),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        SizedBox(width: DesignSystem.spaceM),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return Positioned(
      top: 24,
      left: 24,
      child: WebButton(
        text: '',
        icon: Icons.arrow_back,
        variant: WebButtonVariant.ghost,
        size: WebButtonSize.medium,
        onPressed: () => Navigator.of(context).pop(),
      )
          .animate()
          .fadeIn(duration: 600.ms, delay: 800.ms)
          .slideX(begin: -0.3, end: 0),
    );
  }

  Widget _buildRegistrationForm(BuildContext context, AppLocalizations l10n,
      bool isDark, bool isDesktop) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
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
                                DesignSystem.secondaryGreen,
                                DesignSystem.secondaryGreenDark,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(DesignSystem.radiusXL),
                            boxShadow: [
                              BoxShadow(
                                color: DesignSystem.secondaryGreen
                                    .withOpacity(0.3),
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
                        AppLocalizations.of(context)!.createAccount,
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
                        'Join ${l10n.appTitle} today',
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

                  // Role selection
                  Text(
                    AppLocalizations.of(context)!.accountType,
                    style: DesignSystem.labelLarge(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  )
                      .animate(delay: 250.ms)
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                  SizedBox(height: DesignSystem.spaceM),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRoleCard(
                          'donor',
                          l10n.donor,
                          Icons.volunteer_activism,
                          l10n.helpOthersByDonating,
                          DesignSystem.primaryBlue,
                        )
                            .animate(delay: 300.ms)
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: -0.3, end: 0),
                      ),
                      SizedBox(width: DesignSystem.spaceM),
                      Expanded(
                        child: _buildRoleCard(
                          'receiver',
                          l10n.receiver,
                          Icons.person_outline,
                          l10n.requestWhatYouNeed,
                          DesignSystem.secondaryGreen,
                        )
                            .animate(delay: 350.ms)
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: 0.3, end: 0),
                      ),
                    ],
                  ),

                  SizedBox(height: DesignSystem.spaceXL),

                  // Form fields
                  GBTextField(
                    label: l10n.name,
                    hint: l10n.enterYourName,
                    controller: _nameController,
                    prefixIcon: Icon(
                      Icons.person_outline,
                      size: 20,
                    ),
                    validator: _validateName,
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  SizedBox(height: DesignSystem.spaceL),

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
                      .animate(delay: 450.ms)
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
                  )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),

                  SizedBox(height: DesignSystem.spaceL),

                  Row(
                    children: [
                      Expanded(
                        child: GBTextField(
                          label: '${l10n.phone} (Optional)',
                          hint: l10n.enterYourPhone,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            size: 20,
                          ),
                        )
                            .animate(delay: 550.ms)
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: -0.2, end: 0),
                      ),
                      SizedBox(width: DesignSystem.spaceM),
                      Expanded(
                        child: GBTextField(
                          label: '${l10n.location} (Optional)',
                          hint: l10n.enterYourLocation,
                          controller: _locationController,
                          prefixIcon: Icon(
                            Icons.location_on_outlined,
                            size: 20,
                          ),
                        )
                            .animate(delay: 600.ms)
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: 0.2, end: 0),
                      ),
                    ],
                  ),

                  SizedBox(height: DesignSystem.spaceXXL),

                  // Register button
                  WebButton(
                    text: l10n.signUp,
                    icon: Icons.person_add,
                    variant: WebButtonVariant.primary,
                    size: WebButtonSize.large,
                    fullWidth: true,
                    isLoading: _isLoading,
                    onPressed: _handleRegister,
                  )
                      .animate(delay: 650.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),

                  SizedBox(height: DesignSystem.spaceXL),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${l10n.alreadyHaveAccount} ',
                        style: DesignSystem.bodyMedium(context),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          l10n.signIn,
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

  Widget _buildRoleCard(String value, String title, IconData icon,
      String description, Color color) {
    final isSelected = _selectedRole == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(DesignSystem.spaceL),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          border: Border.all(
            color: isSelected ? color : DesignSystem.getBorderColor(context),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.2)
                    : DesignSystem.neutral100,
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              child: Icon(
                icon,
                color: isSelected ? color : DesignSystem.textSecondary,
                size: 24,
              ),
            ),
            SizedBox(height: DesignSystem.spaceM),
            Text(
              title,
              style: DesignSystem.titleMedium(context).copyWith(
                color: isSelected ? color : null,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            SizedBox(height: DesignSystem.spaceS),
            Text(
              description,
              style: DesignSystem.bodySmall(context).copyWith(
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
