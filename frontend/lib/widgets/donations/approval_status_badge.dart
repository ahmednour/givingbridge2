import 'package:flutter/material.dart';
import '../../models/donation.dart';
import '../../l10n/app_localizations.dart';

class ApprovalStatusBadge extends StatelessWidget {
  final Donation donation;
  final bool showLabel;

  const ApprovalStatusBadge({
    Key? key,
    required this.donation,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Color color;
    IconData icon;
    String text;

    switch (donation.approvalStatus) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        text = l10n.approvalStatusPending;
        break;
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        text = l10n.approvalStatusApproved;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        text = l10n.approvalStatusRejected;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
        text = l10n.approvalStatusUnknown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
