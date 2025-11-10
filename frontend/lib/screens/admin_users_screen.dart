import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = true;
  List<User> _users = [];
  List<User> _filteredUsers = [];
  String _searchQuery = '';
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getAllUsers();
      if (response.success) {
        final users = (response.data?['users'] as List?)
                ?.map((json) => User.fromJson(json))
                .toList() ??
            [];
        setState(() {
          _users = users;
          _filteredUsers = users;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${AppLocalizations.of(context)!.error}: ${response.error}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorLoadingUsers(e.toString()))),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch =
            user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                user.email.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesRole =
            _selectedRole == 'all' || user.role == _selectedRole;
        return matchesSearch && matchesRole;
      }).toList();
    });
  }

  Future<void> _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteUser),
        content:
            Text(AppLocalizations.of(context)!.confirmDeleteUser(user.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final response = await ApiService.deleteUser(user.id.toString());
        if (response.success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.userDeletedSuccessfully)),
            );
          }
          _loadUsers(); // Reload the list
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      '${AppLocalizations.of(context)!.error}: ${response.error}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .errorDeletingUser(e.toString()))),
          );
        }
      }
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Role', user.role.toUpperCase()),
            if (user.phone != null) _buildDetailRow('Phone', user.phone!),
            if (user.location != null)
              _buildDetailRow('Location', user.location!),
            _buildDetailRow('Joined', _formatDate(user.createdAt)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Check if user is admin
    if (authProvider.user?.role != 'admin') {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context)!.noPermissionPage),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterUsers();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('${AppLocalizations.of(context)!.filterByRole} '),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedRole,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                              value: 'all',
                              child:
                                  Text(AppLocalizations.of(context)!.allRoles)),
                          DropdownMenuItem(
                              value: 'donor',
                              child:
                                  Text(AppLocalizations.of(context)!.donors)),
                          DropdownMenuItem(
                              value: 'receiver',
                              child: Text(
                                  AppLocalizations.of(context)!.receivers)),
                          DropdownMenuItem(
                              value: 'admin',
                              child:
                                  Text(AppLocalizations.of(context)!.admins)),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRole = value!);
                          _filterUsers();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: _filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.noUsersFound))
                        : ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              final isCurrentUser =
                                  user.id == authProvider.user?.id;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: user.avatarUrl != null
                                        ? NetworkImage(user.avatarUrl!)
                                        : null,
                                    child: user.avatarUrl == null
                                        ? Text(user.name[0].toUpperCase())
                                        : null,
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(child: Text(user.name)),
                                      if (isCurrentUser)
                                        Chip(
                                          label: Text(
                                              AppLocalizations.of(context)!
                                                  .you),
                                          backgroundColor: Colors.blue,
                                          labelStyle: const TextStyle(
                                              color: Colors.white),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(user.email),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Chip(
                                            label:
                                                Text(user.role.toUpperCase()),
                                            backgroundColor:
                                                _getRoleColor(user.role),
                                            labelStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Joined ${_formatDate(user.createdAt)}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'view':
                                          _showUserDetails(user);
                                          break;
                                        case 'delete':
                                          if (!isCurrentUser) {
                                            _deleteUser(user);
                                          }
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'view',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.visibility),
                                            const SizedBox(width: 8),
                                            Text(AppLocalizations.of(context)!
                                                .viewDetails),
                                          ],
                                        ),
                                      ),
                                      if (!isCurrentUser)
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              const Icon(Icons.delete,
                                                  color: Colors.red),
                                              const SizedBox(width: 8),
                                              Text(AppLocalizations.of(context)!
                                                  .deleteUser),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'donor':
        return Colors.green;
      case 'receiver':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
