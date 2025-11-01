import 'package:flutter/material.dart';

class Request {
  final int id;
  final int donationId;
  final int donorId;
  final String? donorName;
  final int receiverId;
  final String? receiverName;
  final String? receiverEmail;
  final String? receiverPhone;
  final String? message;
  final String status;
  final String? responseMessage;
  final String createdAt;
  final String updatedAt;
  final String? respondedAt;

  Request({
    required this.id,
    required this.donationId,
    required this.donorId,
    this.donorName,
    required this.receiverId,
    this.receiverName,
    this.receiverEmail,
    this.receiverPhone,
    this.message,
    required this.status,
    this.responseMessage,
    required this.createdAt,
    required this.updatedAt,
    this.respondedAt,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      donationId: json['donationId'],
      donorId: json['donorId'],
      donorName: json['donorName'],
      receiverId: json['receiverId'],
      receiverName: json['receiverName'],
      receiverEmail: json['receiverEmail'],
      receiverPhone: json['receiverPhone'],
      message: json['message'],
      status: json['status'],
      responseMessage: json['responseMessage'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      respondedAt: json['respondedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'donationId': donationId,
      'donorId': donorId,
      'donorName': donorName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverEmail': receiverEmail,
      'receiverPhone': receiverPhone,
      'message': message,
      'status': status,
      'responseMessage': responseMessage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'respondedAt': respondedAt,
    };
  }

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'declined':
        return 'Declined';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color get statusColor {
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

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isDeclined => status == 'declined';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}