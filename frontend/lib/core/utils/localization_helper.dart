import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// Helper class for localizing model display names
class LocalizationHelper {
  /// Get localized donation category name
  static String getCategoryDisplayName(BuildContext context, String category) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case 'medical':
        return l10n.medical;
      case 'education':
        return l10n.education;
      case 'food':
        return l10n.food;
      case 'housing':
        return l10n.housing;
      case 'emergency':
        return l10n.emergency;
      case 'clothes':
        return l10n.clothes;
      case 'books':
        return l10n.books;
      case 'electronics':
        return l10n.electronics;
      case 'furniture':
        return l10n.furniture;
      case 'toys':
        return l10n.toys;
      case 'other':
        return l10n.other;
      default:
        return category;
    }
  }

  /// Get localized condition name
  static String getConditionDisplayName(
      BuildContext context, String condition) {
    final l10n = AppLocalizations.of(context)!;
    switch (condition) {
      case 'new':
        return l10n.newCondition;
      case 'like-new':
        return l10n.likeNew;
      case 'good':
        return l10n.good;
      case 'fair':
        return l10n.fair;
      default:
        return condition;
    }
  }

  /// Get localized status name
  static String getStatusDisplayName(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'available':
        return l10n.available;
      case 'pending':
        return l10n.pending;
      case 'completed':
        return l10n.completed;
      case 'cancelled':
        return l10n.cancelled;
      default:
        return status;
    }
  }

  /// Get localized approval status name
  static String getApprovalStatusDisplayName(
      BuildContext context, String approvalStatus) {
    final l10n = AppLocalizations.of(context)!;
    switch (approvalStatus) {
      case 'pending':
        return l10n.pendingReview;
      case 'approved':
        return l10n.approved;
      case 'rejected':
        return l10n.rejected;
      default:
        return approvalStatus;
    }
  }

  /// Get localized request status name
  static String getRequestStatusDisplayName(
      BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'pending':
        return l10n.pending;
      case 'approved':
        return l10n.approved;
      case 'declined':
        return l10n.declined;
      case 'completed':
        return l10n.completed;
      case 'cancelled':
        return l10n.cancelled;
      default:
        return status;
    }
  }

  /// Get localized report reason
  static String getReportReasonDisplayName(
      BuildContext context, String reason) {
    final l10n = AppLocalizations.of(context)!;
    switch (reason) {
      case 'spam':
        return l10n.spam;
      case 'harassment':
        return l10n.harassment;
      case 'inappropriate_content':
        return l10n.inappropriateContent;
      case 'scam':
        return l10n.scam;
      case 'fake_profile':
        return l10n.fakeProfile;
      case 'other':
        return l10n.other;
      default:
        return reason;
    }
  }

  /// Get localized report status
  static String getReportStatusDisplayName(
      BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'pending':
        return l10n.pending;
      case 'reviewed':
        return 'Reviewed'; // TODO: Add to localization
      case 'resolved':
        return 'Resolved'; // TODO: Add to localization
      case 'dismissed':
        return 'Dismissed'; // TODO: Add to localization
      default:
        return status;
    }
  }
}
