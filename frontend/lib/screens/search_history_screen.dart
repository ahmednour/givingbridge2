import 'package:flutter/material.dart';
import '../core/theme/design_system.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  // Mock search history data
  final List<Map<String, dynamic>> _searchHistory = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _searchHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: DesignSystem.spaceM),
                  Text(
                    'No search history',
                    style: DesignSystem.bodyLarge(context).copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _searchHistory.length,
              itemBuilder: (context, index) {
                final item = _searchHistory[index];
                return ListTile(
                  leading: Icon(
                    Icons.search,
                    color: DesignSystem.primaryBlue,
                  ),
                  title: Text(item['query'] ?? ''),
                  subtitle: Text(
                    item['timestamp'] ?? '',
                    style: DesignSystem.bodySmall(context),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeHistoryItem(index),
                  ),
                  onTap: () => _selectHistoryItem(item),
                );
              },
            ),
    );
  }

  void _removeHistoryItem(int index) {
    setState(() {
      _searchHistory.removeAt(index);
    });
  }

  void _selectHistoryItem(Map<String, dynamic> item) {
    Navigator.pop(context, item['query']);
  }
}
