import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/request.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({Key? key}) : super(key: key);

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  bool _isLoading = true;
  List<Request> _requests = [];
  List<Request> _filteredRequests = [];
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.getAllRequests();
      if (response.success) {
        final requests = (response.data?['requests'] as List?)
                ?.map((json) => Request.fromJson(json))
                .toList() ??
            [];
        setState(() {
          _requests = requests;
          _filteredRequests = requests;
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
                  .errorLoadingRequests(e.toString()))),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterRequests() {
    setState(() {
      _filteredRequests = _requests.where((request) {
        return _selectedStatus == 'all' || request.status == _selectedStatus;
      }).toList();
    });
  }

  Future<void> _updateRequestStatus(Request request, String newStatus) async {
    try {
      final response = await ApiService.updateRequestStatus(
        requestId: request.id.toString(),
        status: newStatus,
      );

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .requestUpdatedSuccessfully(newStatus.toLowerCase()))),
          );
        }
        _loadRequests(); // Reload the list
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
                  .errorUpdatingRequest(e.toString()))),
        );
      }
    }
  }

  void _showRequestDetails(Request request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            AppLocalizations.of(context)!.requestNumber(request.id.toString())),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Status', request.status.toUpperCase()),
              _buildDetailRow('Receiver', request.receiverName ?? 'Unknown'),
              _buildDetailRow('Donor', request.donorName ?? 'Unknown'),
              if (request.message != null && request.message!.isNotEmpty)
                _buildDetailRow('Message', request.message!),
              _buildDetailRow('Created', _formatDate(request.createdAt)),
              if (request.respondedAt != null)
                _buildDetailRow('Responded', _formatDate(request.respondedAt!)),
            ],
          ),
        ),
        actions: [
          if (request.status == 'pending') ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateRequestStatus(request, 'approved');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: Text(AppLocalizations.of(context)!.approve),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateRequestStatus(request, 'declined');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(AppLocalizations.of(context)!.decline),
            ),
          ],
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
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.accessDenied)),
        body: Center(
          child: Text(AppLocalizations.of(context)!.noPermissionPage),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.requestManagement),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                Text('${AppLocalizations.of(context)!.filterByStatus} '),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                          value: 'all',
                          child:
                              Text(AppLocalizations.of(context)!.allStatuses)),
                      DropdownMenuItem(
                          value: 'pending',
                          child: Text(AppLocalizations.of(context)!.pending)),
                      DropdownMenuItem(
                          value: 'approved',
                          child: Text(AppLocalizations.of(context)!.approved)),
                      DropdownMenuItem(
                          value: 'declined',
                          child: Text(AppLocalizations.of(context)!.declined)),
                      DropdownMenuItem(
                          value: 'completed',
                          child: Text(AppLocalizations.of(context)!.completed)),
                      DropdownMenuItem(
                          value: 'cancelled',
                          child: Text(AppLocalizations.of(context)!.cancelled)),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedStatus = value!);
                      _filterRequests();
                    },
                  ),
                ),
              ],
            ),
          ),
          // Requests list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadRequests,
                    child: _filteredRequests.isEmpty
                        ? Center(
                            child: Text(
                                AppLocalizations.of(context)!.noRequestsFound))
                        : ListView.builder(
                            itemCount: _filteredRequests.length,
                            itemBuilder: (context, index) {
                              final request = _filteredRequests[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                child: ListTile(
                                  title: Text(AppLocalizations.of(context)!
                                      .requestNumber(request.id.toString())),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(AppLocalizations.of(context)!
                                          .fromUser(request.receiverName ??
                                              'Unknown')),
                                      Text(AppLocalizations.of(context)!.toUser(
                                          request.donorName ?? 'Unknown')),
                                      if (request.message != null &&
                                          request.message!.isNotEmpty)
                                        Text(
                                          request.message!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Created: ${_formatDate(request.createdAt)}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Chip(
                                        label:
                                            Text(request.status.toUpperCase()),
                                        backgroundColor:
                                            _getStatusColor(request.status),
                                        labelStyle: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      if (request.status == 'pending')
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            _updateRequestStatus(
                                                request, value);
                                          },
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                              value: 'approved',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.check,
                                                      color: Colors.green),
                                                  SizedBox(width: 8),
                                                  Text(AppLocalizations.of(
                                                          context)!
                                                      .approve),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem(
                                              value: 'declined',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.close,
                                                      color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text(AppLocalizations.of(
                                                          context)!
                                                      .decline),
                                                ],
                                              ),
                                            ),
                                          ],
                                          child: const Icon(Icons.more_vert),
                                        ),
                                    ],
                                  ),
                                  onTap: () => _showRequestDetails(request),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
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
