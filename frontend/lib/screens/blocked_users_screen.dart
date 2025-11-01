import 'package:flutter/material.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  List<Map<String, dynamic>> blockedUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    // TODO: Implement API call to load blocked users
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _unblockUser(String userId) async {
    // TODO: Implement API call to unblock user
    setState(() {
      blockedUsers.removeWhere((user) => user['id'] == userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Users'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : blockedUsers.isEmpty
              ? const Center(
                  child: Text(
                    'No blocked users',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: blockedUsers.length,
                  itemBuilder: (context, index) {
                    final user = blockedUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user['name']?[0] ?? 'U'),
                      ),
                      title: Text(user['name'] ?? 'Unknown User'),
                      subtitle: Text(user['email'] ?? ''),
                      trailing: TextButton(
                        onPressed: () => _unblockUser(user['id']),
                        child: const Text('Unblock'),
                      ),
                    );
                  },
                ),
    );
  }
}