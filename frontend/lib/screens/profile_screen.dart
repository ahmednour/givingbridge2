import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/design_system.dart';
import '../widgets/common/gb_image_upload.dart';
import '../widgets/common/gb_button.dart';
import '../widgets/common/web_card.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        // If no user, show error screen
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 80,
                    color: DesignSystem.error,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Unable to load profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(AppLocalizations.of(context)!.pleaseLoginAgain),
                  const SizedBox(height: 30),
                  GBButton(
                    text: 'Logout',
                    onPressed: () async {
                      await authProvider.logout();
                      if (mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      }
                    },
                    variant: GBButtonVariant.danger,
                    size: GBButtonSize.medium,
                  ),
                ],
              ),
            ),
          );
        }

        // Normal profile screen
        return Scaffold(
          backgroundColor: DesignSystem.getBackgroundColor(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(DesignSystem.spaceXL),
            child: Column(
              children: [
                // Profile Avatar
                _buildProfileAvatar(user)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(),
                const SizedBox(height: DesignSystem.spaceXXL),

                // Profile Information Card
                _buildProfileCard(user)
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: DesignSystem.spaceXL),

                // Settings Card
                _buildSettingsCard()
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: DesignSystem.spaceXL),

                // Logout Button
                _buildLogoutButton(authProvider)
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(user) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: DesignSystem.primaryBlue.withOpacity(0.1),
              child: user.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        user.avatarUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 60,
                            color: DesignSystem.primaryBlue,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 60,
                      color: DesignSystem.primaryBlue,
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: DesignSystem.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: DesignSystem.elevation2,
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 20),
                  color: Colors.white,
                  onPressed: () => _showAvatarUploadDialog(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignSystem.spaceL),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: DesignSystem.textPrimary,
          ),
        ),
        const SizedBox(height: DesignSystem.spaceS),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceL, vertical: DesignSystem.spaceS),
          decoration: BoxDecoration(
            color: DesignSystem.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignSystem.radiusPill),
          ),
          child: Text(
            _getRoleLabel(user.role),
            style: const TextStyle(
              color: DesignSystem.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                      if (!_isEditing) {
                        // Reset controllers when canceling
                        _nameController.text = user.name;
                        _phoneController.text = user.phone ?? '';
                        _locationController.text = user.location ?? '';
                      }
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            if (_isEditing) _buildEditForm(user) else _buildInfoDisplay(user),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoDisplay(user) {
    return Column(
      children: [
        _buildInfoRow(Icons.person, 'Name', user.name),
        const SizedBox(height: 15),
        _buildInfoRow(Icons.email, 'Email', user.email),
        const SizedBox(height: 15),
        _buildInfoRow(Icons.phone, 'Phone', user.phone ?? 'Not provided'),
        const SizedBox(height: 15),
        _buildInfoRow(
            Icons.location_on, 'Location', user.location ?? 'Not provided'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(DesignSystem.spaceS),
          decoration: BoxDecoration(
            color: DesignSystem.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          ),
          child: Icon(icon, color: DesignSystem.primaryBlue, size: 20),
        ),
        const SizedBox(width: DesignSystem.spaceL),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: DesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: DesignSystem.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(user) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.name,
              prefixIcon: const Icon(Icons.person),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.phone,
              prefixIcon: const Icon(Icons.phone),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _locationController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.location,
              prefixIcon: const Icon(Icons.location_on),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _nameController.text = user.name;
                      _phoneController.text = user.phone ?? '';
                      _locationController.text = user.location ?? '';
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GBButton(
                  text: 'Save Changes',
                  onPressed: () => _saveProfile(),
                  variant: GBButtonVariant.primary,
                  size: GBButtonSize.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return WebCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(DesignSystem.spaceS),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  ),
                  child: const Icon(
                    Icons.dark_mode,
                    color: DesignSystem.primaryBlue,
                  ),
                ),
                title: Text(AppLocalizations.of(context)!.darkMode),
                subtitle: Text(AppLocalizations.of(context)!.darkModeDesc),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(DesignSystem.spaceS),
              decoration: BoxDecoration(
                color: DesignSystem.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              child: const Icon(
                Icons.notifications,
                color: DesignSystem.primaryBlue,
              ),
            ),
            title: Text(AppLocalizations.of(context)!.notifications),
            subtitle: Text(AppLocalizations.of(context)!.notificationsDesc),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(DesignSystem.spaceS),
              decoration: BoxDecoration(
                color: DesignSystem.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
              ),
              child: const Icon(
                Icons.language,
                color: DesignSystem.primaryBlue,
              ),
            ),
            title: Text(AppLocalizations.of(context)!.language),
            subtitle: Text(AppLocalizations.of(context)!.languageDesc),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.languageSettingsComingSoon),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(authProvider),
        icon: const Icon(Icons.logout),
        label: Text(AppLocalizations.of(context)!.logout),
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignSystem.error,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
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
          SnackBar(
            content: Text(AppLocalizations.of(context)!.profileUpdatedSuccess),
            backgroundColor: DesignSystem.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToUpdateProfile),
            backgroundColor: DesignSystem.error,
          ),
        );
      }
    }
  }

  Future<void> _showLogoutDialog(AuthProvider authProvider) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.error,
            ),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
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

  Future<void> _showAvatarUploadDialog() async {
    Uint8List? selectedImageData;
    String? selectedImageName;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.updateProfilePicture),
          content: SizedBox(
            width: 400,
            child: GBImageUpload(
              label: 'Profile Picture',
              helperText: 'Choose a clear photo of yourself',
              maxSizeMB: 2.0,
              width: double.infinity,
              height: 300,
              onImageSelected: (bytes, name) {
                setDialogState(() {
                  selectedImageData = bytes;
                  selectedImageName = name;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: selectedImageData != null
                  ? () {
                      Navigator.pop(context);
                      _uploadAvatar(selectedImageData!, selectedImageName!);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignSystem.primaryBlue,
              ),
              child: Text(AppLocalizations.of(context)!.upload),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAvatar(Uint8List imageData, String imageName) async {
    // Show loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(AppLocalizations.of(context)!.uploadingAvatar),
          ],
        ),
        duration: const Duration(seconds: 30),
        backgroundColor: DesignSystem.primaryBlue,
      ),
    );

    try {
      // Convert Uint8List to File then to XFile for web compatibility
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$imageName');
      await file.writeAsBytes(imageData);

      // Convert File to XFile
      final xFile = XFile(file.path);

      // Upload avatar to backend
      final response = await ApiService.uploadAvatar(xFile);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        if (response.success && response.data != null) {
          // Manually update the user in auth provider
          // We access the private field through reflection is not possible,
          // so we'll call updateProfile with the new avatarUrl
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);

          // The user object is already updated in the API response,
          // we just need to trigger a refresh of the profile
          await authProvider.updateProfile(
            avatarUrl: response.data!.avatarUrl,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context)!.avatarUploadedSuccess),
                ],
              ),
              backgroundColor: DesignSystem.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(response.error ?? 'Failed to upload avatar'),
                  ),
                ],
              ),
              backgroundColor: DesignSystem.error,
            ),
          );
        }
      }

      // Clean up temp file
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                      '${AppLocalizations.of(context)!.errorUploadingAvatar}: $e'),
                ),
              ],
            ),
            backgroundColor: DesignSystem.error,
          ),
        );
      }
    }
  }

  String _getRoleLabel(String role) {
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
