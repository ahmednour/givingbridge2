import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../core/theme/design_system.dart';
import 'dart:async';

class StartConversationDialog extends StatefulWidget {
  const StartConversationDialog({Key? key}) : super(key: key);

  @override
  State<StartConversationDialog> createState() =>
      _StartConversationDialogState();
}

class _StartConversationDialogState extends State<StartConversationDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.searchUsers(query);
      if (response.success && response.data != null) {
        setState(() {
          _searchResults = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToSearchUsersError(error.toString())),
            backgroundColor: DesignSystem.error,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchUsers(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DesignSystem.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: DesignSystem.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.newConversation,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: DesignSystem.neutral900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.searchUserToChat,
                        style: const TextStyle(
                          fontSize: 14,
                          color: DesignSystem.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: DesignSystem.neutral600,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Field
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchByNameEmailLocation,
                prefixIcon:
                    const Icon(Icons.search, color: DesignSystem.neutral600),
                filled: true,
                fillColor: DesignSystem.neutral100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  borderSide: const BorderSide(
                      color: DesignSystem.primaryBlue, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),

            // Search Results
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            DesignSystem.primaryBlue),
                      ),
                    )
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchController.text.isEmpty
                                    ? Icons.person_search
                                    : Icons.search_off,
                                size: 64,
                                color: DesignSystem.neutral400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? AppLocalizations.of(context)!.startTypingToSearch
                                    : AppLocalizations.of(context)!.noUsersFound,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: DesignSystem.neutral600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _searchResults.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            color: DesignSystem.neutral200,
                          ),
                          itemBuilder: (context, index) {
                            final user = _searchResults[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    DesignSystem.primaryBlue.withOpacity(0.1),
                                backgroundImage: user.avatarUrl != null &&
                                        user.avatarUrl!.isNotEmpty
                                    ? NetworkImage(user.avatarUrl!)
                                    : null,
                                child: user.avatarUrl == null ||
                                        user.avatarUrl!.isEmpty
                                    ? Text(
                                        user.name[0].toUpperCase(),
                                        style: const TextStyle(
                                          color: DesignSystem.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      )
                                    : null,
                              ),
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: DesignSystem.neutral900,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (user.location != null &&
                                      user.location!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: DesignSystem.neutral600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          user.location!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: DesignSystem.neutral600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getRoleColor(user.role)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getRoleLabel(user.role),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getRoleColor(user.role),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                color: DesignSystem.neutral400,
                              ),
                              onTap: () => Navigator.of(context).pop(user),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'donor':
        return DesignSystem.primaryBlue;
      case 'receiver':
        return DesignSystem.secondaryGreen;
      case 'admin':
        return DesignSystem.accentPink;
      default:
        return DesignSystem.neutral600;
    }
  }

  String _getRoleLabel(String role) {
    final l10n = AppLocalizations.of(context)!;
    switch (role.toLowerCase()) {
      case 'donor':
        return l10n.donor;
      case 'receiver':
        return l10n.receiver;
      case 'admin':
        return l10n.admin;
      default:
        return role;
    }
  }
}
