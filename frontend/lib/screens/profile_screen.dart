import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_input.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
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
        padding:
            EdgeInsets.all(isDesktop ? AppTheme.spacingXL : AppTheme.spacingM),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(context, theme, isDark),

              const SizedBox(height: AppTheme.spacingXL),

              // Profile Information
              _buildProfileInfo(context, theme, isDark),

              const SizedBox(height: AppTheme.spacingXL),

              // Settings
              _buildSettings(context, theme, isDark),

              const SizedBox(height: AppTheme.spacingXL),

              // Actions
              _buildActions(context, theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return CustomCard(
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    width: 3,
                  ),
                ),
                child: user?.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(47),
                        child: Image.network(
                          user!.avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 50,
                              color: AppTheme.primaryColor,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
              ),

              // Edit button
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.shadowSM,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.avatarUploadComingSoon),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          // Name and Role
          Text(
            user?.name ?? 'User',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: AppTheme.spacingXS),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: AppTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            ),
            child: Text(
              _getRoleLabel(user?.role),
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          if (user?.location != null) ...[
            const SizedBox(height: AppTheme.spacingS),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: isDark
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: AppTheme.spacingXS),
                Text(
                  user!.location!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondaryColor
                        : AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileInfo(BuildContext context, ThemeData theme, bool isDark) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Profile Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              GhostButton(
                text: _isEditing ? 'Cancel' : 'Edit',
                size: ButtonSize.small,
                leftIcon: Icon(
                  _isEditing ? Icons.close : Icons.edit,
                  size: 16,
                ),
                onPressed: () {
                  setState(() => _isEditing = !_isEditing);
                  if (!_isEditing) {
                    // Reset form when cancelling
                    final user =
                        Provider.of<AuthProvider>(context, listen: false).user;
                    _nameController.text = user?.name ?? '';
                    _emailController.text = user?.email ?? '';
                    _phoneController.text = user?.phone ?? '';
                    _locationController.text = user?.location ?? '';
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingL),

          if (_isEditing)
            _buildEditForm(context, theme)
          else
            _buildInfoDisplay(context, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoDisplay(BuildContext context, ThemeData theme, bool isDark) {
    final user = Provider.of<AuthProvider>(context).user;

    return Column(
      children: [
        _buildInfoRow('Name', user?.name ?? 'Not provided',
            Icons.person_outline, theme, isDark),
        _buildInfoRow('Email', user?.email ?? 'Not provided',
            Icons.email_outlined, theme, isDark),
        _buildInfoRow('Phone', user?.phone ?? 'Not provided',
            Icons.phone_outlined, theme, isDark),
        _buildInfoRow('Location', user?.location ?? 'Not provided',
            Icons.location_on_outlined, theme, isDark),
        _buildInfoRow('Role', _getRoleLabel(user?.role), Icons.badge_outlined,
            theme, isDark),
      ],
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.darkCardColor : AppTheme.cardColor),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isDark
                  ? AppTheme.darkTextSecondaryColor
                  : AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isDark
                        ? AppTheme.darkTextSecondaryColor
                        : AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(BuildContext context, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomInput(
            label: 'Full Name',
            controller: _nameController,
            prefixIcon: const Icon(Icons.person_outline),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: AppTheme.spacingM),
          CustomInput(
            label: 'Email',
            controller: _emailController,
            enabled: false, // Email usually can't be changed
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: AppTheme.spacingM),
          CustomInput(
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
          const SizedBox(height: AppTheme.spacingM),
          CustomInput(
            label: 'Location',
            controller: _locationController,
            prefixIcon: const Icon(Icons.location_on_outlined),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            children: [
              Expanded(
                child: OutlineButton(
                  text: l10n.cancel,
                  onPressed: () => setState(() => _isEditing = false),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: PrimaryButton(
                  text: l10n.saveChanges,
                  onPressed: _saveProfile,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppTheme.spacingL),

          // Theme setting
          _buildSettingTile(
            title: 'Dark Mode',
            subtitle: 'Toggle dark/light theme',
            icon: Icons.dark_mode_outlined,
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeColor: AppTheme.primaryColor,
            ),
            theme: theme,
            isDark: isDark,
          ),

          // Notifications setting
          _buildSettingTile(
            title: 'Push Notifications',
            subtitle: 'Receive notifications about donations',
            icon: Icons.notifications_outlined,
            trailing: Switch(
              value: true, // TODO: Implement notification settings
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.notificationSettingsComingSoon),
                  ),
                );
              },
              activeColor: AppTheme.primaryColor,
            ),
            theme: theme,
            isDark: isDark,
          ),

          // Language setting
          _buildSettingTile(
            title: 'Language',
            subtitle: 'Change app language',
            icon: Icons.language_outlined,
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark
                  ? AppTheme.textDisabledColor
                  : AppTheme.textDisabledColor,
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.languageSettingsComingSoon),
                ),
              );
            },
            theme: theme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
    required ThemeData theme,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppTheme.darkTextSecondaryColor
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Help & Support
        CustomCard(
          isInteractive: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.helpSupportComingSoon),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  Icons.help_outline,
                  size: 20,
                  color: AppTheme.infoColor,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Help & Support',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Get help and contact support',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppTheme.darkTextSecondaryColor
                            : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark
                    ? AppTheme.textDisabledColor
                    : AppTheme.textDisabledColor,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppTheme.spacingM),

        // Logout
        DangerButton(
          text: l10n.logout,
          width: double.infinity,
          leftIcon: const Icon(Icons.logout, size: 20),
          onPressed: _logout,
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
    );

    if (success) {
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    }
  }

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'donor':
        return 'Donor';
      case 'receiver':
        return 'Receiver';
      case 'admin':
        return 'Administrator';
      default:
        return 'User';
    }
  }
}
