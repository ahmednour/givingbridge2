import 'package:flutter/material.dart';

enum ReportReason {
  spam,
  harassment,
  inappropriateContent,
  scam,
  fakeProfile,
  other;

  String get displayName {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.inappropriateContent:
        return 'Inappropriate Content';
      case ReportReason.scam:
        return 'Scam or Fraud';
      case ReportReason.fakeProfile:
        return 'Fake Profile';
      case ReportReason.other:
        return 'Other';
    }
  }

  String get apiValue {
    switch (this) {
      case ReportReason.spam:
        return 'spam';
      case ReportReason.harassment:
        return 'harassment';
      case ReportReason.inappropriateContent:
        return 'inappropriate_content';
      case ReportReason.scam:
        return 'scam';
      case ReportReason.fakeProfile:
        return 'fake_profile';
      case ReportReason.other:
        return 'other';
    }
  }

  static ReportReason fromApiValue(String value) {
    switch (value) {
      case 'spam':
        return ReportReason.spam;
      case 'harassment':
        return ReportReason.harassment;
      case 'inappropriate_content':
        return ReportReason.inappropriateContent;
      case 'scam':
        return ReportReason.scam;
      case 'fake_profile':
        return ReportReason.fakeProfile;
      case 'other':
        return ReportReason.other;
      default:
        return ReportReason.other;
    }
  }
}

enum ReportStatus {
  pending,
  reviewed,
  resolved,
  dismissed;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.reviewed:
        return 'Under Review';
      case ReportStatus.resolved:
        return 'Resolved';
      case ReportStatus.dismissed:
        return 'Dismissed';
    }
  }

  Color get color {
    switch (this) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.reviewed:
        return Colors.blue;
      case ReportStatus.resolved:
        return Colors.green;
      case ReportStatus.dismissed:
        return Colors.grey;
    }
  }

  static ReportStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ReportStatus.pending;
      case 'reviewed':
        return ReportStatus.reviewed;
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }
}

class UserReport {
  final int id;
  final int reporterId;
  final int reportedId;
  final ReportReason reason;
  final String description;
  final ReportStatus status;
  final int? reviewedBy;
  final String? reviewNotes;
  final String createdAt;
  final String updatedAt;
  final String? reviewedAt;
  final ReporterInfo? reporter;
  final ReportedUserInfo? reportedUser;

  UserReport({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    required this.reason,
    required this.description,
    required this.status,
    this.reviewedBy,
    this.reviewNotes,
    required this.createdAt,
    required this.updatedAt,
    this.reviewedAt,
    this.reporter,
    this.reportedUser,
  });

  factory UserReport.fromJson(Map<String, dynamic> json) {
    return UserReport(
      id: json['id'],
      reporterId: json['reporterId'],
      reportedId: json['reportedId'],
      reason: ReportReason.fromApiValue(json['reason']),
      description: json['description'],
      status: ReportStatus.fromString(json['status']),
      reviewedBy: json['reviewedBy'],
      reviewNotes: json['reviewNotes'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      reviewedAt: json['reviewedAt'],
      reporter: json['reporter'] != null
          ? ReporterInfo.fromJson(json['reporter'])
          : null,
      reportedUser: json['reportedUser'] != null
          ? ReportedUserInfo.fromJson(json['reportedUser'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporterId': reporterId,
      'reportedId': reportedId,
      'reason': reason.apiValue,
      'description': description,
      'status': status.name,
      'reviewedBy': reviewedBy,
      'reviewNotes': reviewNotes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'reviewedAt': reviewedAt,
      if (reporter != null) 'reporter': reporter!.toJson(),
      if (reportedUser != null) 'reportedUser': reportedUser!.toJson(),
    };
  }

  bool get isPending => status == ReportStatus.pending;
  bool get isReviewed => status == ReportStatus.reviewed;
  bool get isResolved => status == ReportStatus.resolved;
  bool get isDismissed => status == ReportStatus.dismissed;
}

class ReporterInfo {
  final int id;
  final String name;
  final String email;

  ReporterInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ReporterInfo.fromJson(Map<String, dynamic> json) {
    return ReporterInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class ReportedUserInfo {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? avatarUrl;

  ReportedUserInfo({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.avatarUrl,
  });

  factory ReportedUserInfo.fromJson(Map<String, dynamic> json) {
    return ReportedUserInfo(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }
}
