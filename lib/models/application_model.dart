import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  pending,
  reviewed,
  shortlisted,
  rejected,
  hired,
  interviewScheduled,
  interviewCompleted,
  offered,
  withdrawn
}

extension ApplicationStatusExtension on ApplicationStatus {
  String get display {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.reviewed:
        return 'Reviewed';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.hired:
        return 'Hired';
      case ApplicationStatus.interviewScheduled:
        return 'Interview Scheduled';
      case ApplicationStatus.interviewCompleted:
        return 'Interview Completed';
      case ApplicationStatus.offered:
        return 'Offered';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}

class ApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String applicantId;
  final String applicantName;
  final String? applicantEmail;
  final String? employerName;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? updatedAt;
  final double? matchScore;
  final String? coverLetter;
  final String? resumeUrl;
  final Map<String, dynamic>? aiAnalysis;
  final Map<String, dynamic>? additionalData;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.applicantId,
    required this.applicantName,
    this.applicantEmail,
    this.employerName,
    required this.status,
    required this.appliedAt,
    this.updatedAt,
    this.matchScore,
    this.coverLetter,
    this.resumeUrl,
    this.aiAnalysis,
    this.additionalData,
  });

  // Factory constructor for creating from Firestore
  factory ApplicationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id: doc.id,
      jobId: data['jobId'] ?? '',
      jobTitle: data['jobTitle'] ?? '',
      applicantId: data['applicantId'] ?? '',
      applicantName: data['applicantName'] ?? '',
      applicantEmail: data['applicantEmail'],
      employerName: data['employerName'],
      status: _parseStatus(data['status']),
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      matchScore: data['matchScore']?.toDouble(),
      coverLetter: data['coverLetter'],
      resumeUrl: data['resumeUrl'],
      aiAnalysis: data['aiAnalysis'] as Map<String, dynamic>?,
      additionalData: data,
    );
  }

  // Factory constructor for creating from JSON (for navigation)
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] ?? '',
      jobId: json['jobId'] ?? '',
      jobTitle: json['jobTitle'] ?? '',
      applicantId: json['applicantId'] ?? '',
      applicantName: json['applicantName'] ?? '',
      applicantEmail: json['applicantEmail'],
      employerName: json['employerName'],
      status: _parseStatus(json['status']),
      appliedAt: _parseDate(json['appliedAt']),
      updatedAt: json['updatedAt'] != null ? _parseDate(json['updatedAt']) : null,
      matchScore: json['matchScore']?.toDouble(),
      coverLetter: json['coverLetter'],
      resumeUrl: json['resumeUrl'],
      aiAnalysis: json['aiAnalysis'] as Map<String, dynamic>?,
      additionalData: json,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'employerName': employerName,
      'status': status.toString().split('.').last,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'matchScore': matchScore,
      'coverLetter': coverLetter,
      'resumeUrl': resumeUrl,
      'aiAnalysis': aiAnalysis,
    };
  }

  // Convert to JSON (for navigation)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'jobTitle': jobTitle,
      'applicantId': applicantId,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'employerName': employerName,
      'status': status.toString().split('.').last,
      'appliedAt': appliedAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'matchScore': matchScore,
      'coverLetter': coverLetter,
      'resumeUrl': resumeUrl,
      'aiAnalysis': aiAnalysis,
    };
  }

  // Parse status from string
  static ApplicationStatus _parseStatus(String? status) {
    if (status == null) return ApplicationStatus.pending;
    switch (status.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'reviewed':
        return ApplicationStatus.reviewed;
      case 'shortlisted':
        return ApplicationStatus.shortlisted;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'hired':
        return ApplicationStatus.hired;
      case 'interviewscheduled':
      case 'interview_scheduled':
        return ApplicationStatus.interviewScheduled;
      case 'interviewcompleted':
      case 'interview_completed':
        return ApplicationStatus.interviewCompleted;
      case 'offered':
        return ApplicationStatus.offered;
      case 'withdrawn':
        return ApplicationStatus.withdrawn;
      default:
        return ApplicationStatus.pending;
    }
  }

  // Parse date from various formats
  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.parse(date);
    return DateTime.now();
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(appliedAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Helper class for status colors and icons
class ApplicationStatusColors {
  static Color getColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.reviewed:
        return Colors.blue;
      case ApplicationStatus.shortlisted:
        return Colors.teal;
      case ApplicationStatus.rejected:
        return Colors.red;
      case ApplicationStatus.hired:
        return Colors.green;
      case ApplicationStatus.interviewScheduled:
        return Colors.purple;
      case ApplicationStatus.interviewCompleted:
        return Colors.indigo;
      case ApplicationStatus.offered:
        return Colors.amber;
      case ApplicationStatus.withdrawn:
        return Colors.grey;
    }
  }

  static IconData getIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Icons.hourglass_empty;
      case ApplicationStatus.reviewed:
        return Icons.visibility;
      case ApplicationStatus.shortlisted:
        return Icons.star;
      case ApplicationStatus.rejected:
        return Icons.cancel;
      case ApplicationStatus.hired:
        return Icons.work;
      case ApplicationStatus.interviewScheduled:
        return Icons.event;
      case ApplicationStatus.interviewCompleted:
        return Icons.event_available;
      case ApplicationStatus.offered:
        return Icons.card_giftcard;
      case ApplicationStatus.withdrawn:
        return Icons.exit_to_app;
    }
  }
}