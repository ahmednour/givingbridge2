import 'package:flutter/material.dart';
import '../models/donation.dart';
import '../services/api_service.dart';
import '../widgets/donations/approval_status_badge.dart';
import '../l10n/app_localizations.dart';

class AdminPendingDonationsScreen extends StatefulWidget {
  const AdminPendingDonationsScreen({Key? key}) : super(key: key);

  @override
  State<AdminPendingDonationsScreen> createState() =>
      _AdminPendingDonationsScreenState();
}

class _AdminPendingDonationsScreenState
    extends State<AdminPendingDonationsScreen> {
  List<Donation> _donations = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadPendingDonations();
  }

  Future<void> _loadPendingDonations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await ApiService.getPendingDonations(
      page: _currentPage,
      limit: 20,
    );

    if (response.success && response.data != null) {
      setState(() {
        _donations = response.data!.items;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = response.error ?? 'Failed to load pending donations';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveDonation(Donation donation) async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.approveDonation),
        content: Text(l10n.areYouSureApprove(donation.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(l10n.approve),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await ApiService.approveDonation(donation.id);

    if (mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.donationApprovedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
        _loadPendingDonations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? l10n.failedToApproveDonation),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectDonation(Donation donation) async {
    final l10n = AppLocalizations.of(context)!;
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.rejectDonation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.rejecting(donation.title)),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: l10n.rejectionReason,
                hintText: l10n.provideRejectionReason,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.pleaseProvideRejectionReason),
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.reject),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await ApiService.rejectDonation(
      donation.id,
      reasonController.text.trim(),
    );

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.donationRejectedSuccessfully),
            backgroundColor: Colors.orange,
          ),
        );
        _loadPendingDonations();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.error ?? l10n.failedToRejectDonation),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPendingDonations,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _donations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 64, color: Colors.green),
                          const SizedBox(height: 16),
                          Text(l10n.noPendingDonations,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 8),
                          Text(l10n.noPendingDonationsMessage,
                              style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _donations.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final donation = _donations[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        donation.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    ApprovalStatusBadge(donation: donation),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${l10n.donorName}: ${donation.donorName}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  donation.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Chip(
                                      label: Text(donation.categoryDisplayName),
                                      backgroundColor:
                                          Colors.blue.withOpacity(0.1),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label:
                                          Text(donation.conditionDisplayName),
                                      backgroundColor:
                                          Colors.green.withOpacity(0.1),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 4),
                                    Text(donation.location),
                                  ],
                                ),
                                if (donation.imageUrl != null) ...[
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      donation.imageUrl!,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 200,
                                          color: Colors.grey[300],
                                          child:
                                              const Icon(Icons.image, size: 64),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            _approveDonation(donation),
                                        icon: const Icon(Icons.check),
                                        label: Text(l10n.approve),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _rejectDonation(donation),
                                        icon: const Icon(Icons.close),
                                        label: Text(l10n.reject),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                              color: Colors.red),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
