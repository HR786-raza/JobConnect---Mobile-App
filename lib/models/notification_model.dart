import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

enum NotificationType {
  jobMatch,
  applicationUpdate,
  interviewSchedule,
  message,
  jobAlert,
  system,
  resumeFeedback,
  offer,
  reminder
}

enum NotificationPriority { low, normal, high, urgent }

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? imageUrl;
  final String? actionUrl;
  final NotificationPriority priority;
  final Map<String, dynamic>? metadata;
  final String? platform; // Track which platform notification came from

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.expiresAt,
    this.imageUrl,
    this.actionUrl,
    this.priority = NotificationPriority.normal,
    this.metadata,
    this.platform,
  });

  // Factory constructor for creating from Firestore
  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return NotificationModel(
      id: doc.id,
      userId: _getStringValue(data, 'userId', ''),
      type: _parseNotificationType(_getStringValue(data, 'type', null)),
      title: _getStringValue(data, 'title', ''),
      body: _getStringValue(data, 'body', ''),
      data: data['data'] as Map<String, dynamic>?,
      isRead: _getBoolValue(data, 'isRead', false),
      // FIXED: Handle nullable DateTime properly
      createdAt: _getDateTimeValue(data, 'createdAt') ?? DateTime.now(),
      expiresAt: _getDateTimeValue(data, 'expiresAt'),
      imageUrl: _getStringValue(data, 'imageUrl', null),
      actionUrl: _getStringValue(data, 'actionUrl', null),
      priority: _parseNotificationPriority(_getStringValue(data, 'priority', null)),
      metadata: data['metadata'] as Map<String, dynamic>?,
      platform: _getStringValue(data, 'platform', null),
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'priority': priority.toString().split('.').last,
      'metadata': metadata,
      'platform': platform ?? (kIsWeb ? 'web' : 'mobile'),
    };
  }

  // Convert to JSON for web storage/local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'priority': priority.toString().split('.').last,
      'metadata': metadata,
      'platform': platform,
    };
  }

  // Factory constructor for creating from JSON (web/local storage)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: _parseNotificationType(json['type']),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
      priority: _parseNotificationPriority(json['priority']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      platform: json['platform'],
    );
  }

  // Helper methods for safe data extraction
  static String _getStringValue(Map<String, dynamic> data, String key, String? defaultValue) {
    if (data.containsKey(key) && data[key] != null) {
      return data[key].toString();
    }
    return defaultValue ?? '';
  }

  static bool _getBoolValue(Map<String, dynamic> data, String key, bool defaultValue) {
    if (data.containsKey(key) && data[key] != null) {
      return data[key] as bool;
    }
    return defaultValue;
  }

  // FIXED: Changed to return nullable DateTime
  static DateTime? _getDateTimeValue(Map<String, dynamic> data, String key) {
    if (data.containsKey(key) && data[key] != null) {
      if (data[key] is Timestamp) {
        return (data[key] as Timestamp).toDate();
      } else if (data[key] is String) {
        return DateTime.parse(data[key]);
      }
    }
    return null;
  }

  static NotificationType _parseNotificationType(String? type) {
    if (type == null) return NotificationType.system;
    switch (type) {
      case 'jobMatch': return NotificationType.jobMatch;
      case 'applicationUpdate': return NotificationType.applicationUpdate;
      case 'interviewSchedule': return NotificationType.interviewSchedule;
      case 'message': return NotificationType.message;
      case 'jobAlert': return NotificationType.jobAlert;
      case 'system': return NotificationType.system;
      case 'resumeFeedback': return NotificationType.resumeFeedback;
      case 'offer': return NotificationType.offer;
      case 'reminder': return NotificationType.reminder;
      default: return NotificationType.system;
    }
  }

  static NotificationPriority _parseNotificationPriority(String? priority) {
    if (priority == null) return NotificationPriority.normal;
    switch (priority) {
      case 'low': return NotificationPriority.low;
      case 'normal': return NotificationPriority.normal;
      case 'high': return NotificationPriority.high;
      case 'urgent': return NotificationPriority.urgent;
      default: return NotificationPriority.normal;
    }
  }

  // Create a copy with modified fields
  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? expiresAt,
    String? imageUrl,
    String? actionUrl,
    NotificationPriority? priority,
    Map<String, dynamic>? metadata,
    String? platform,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      priority: priority ?? this.priority,
      metadata: metadata ?? this.metadata,
      platform: platform ?? this.platform,
    );
  }

  // Mark as read
  NotificationModel markAsRead() {
    return copyWith(isRead: true);
  }

  // Check if notification is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }

  // Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  // Get color based on priority
  String get priorityColor {
    switch (priority) {
      case NotificationPriority.low:
        return 'green';
      case NotificationPriority.normal:
        return 'blue';
      case NotificationPriority.high:
        return 'orange';
      case NotificationPriority.urgent:
        return 'red';
    }
  }

  // Get icon based on type
  String get typeIcon {
    switch (type) {
      case NotificationType.jobMatch:
        return 'work';
      case NotificationType.applicationUpdate:
        return 'update';
      case NotificationType.interviewSchedule:
        return 'event';
      case NotificationType.message:
        return 'message';
      case NotificationType.jobAlert:
        return 'notification';
      case NotificationType.resumeFeedback:
        return 'description';
      case NotificationType.offer:
        return 'local_offer';
      case NotificationType.reminder:
        return 'alarm';
      case NotificationType.system:
        return 'info';
    }
  }
}

class JobAlertModel {
  final String id;
  final String userId;
  final String title;
  final List<String> keywords;
  final String? location;
  final String? jobType;
  final double? salaryMin;
  final double? salaryMax;
  final List<String>? categories;
  final bool isActive;
  final String frequency; // daily, weekly, instant
  final DateTime createdAt;
  final DateTime? lastTriggered;
  final int notificationCount;
  final Map<String, dynamic>? filters; // Additional filters

  JobAlertModel({
    required this.id,
    required this.userId,
    required this.title,
    this.keywords = const [],
    this.location,
    this.jobType,
    this.salaryMin,
    this.salaryMax,
    this.categories,
    this.isActive = true,
    this.frequency = 'daily',
    required this.createdAt,
    this.lastTriggered,
    this.notificationCount = 0,
    this.filters,
  });

  // Factory constructor for creating from Firestore
  factory JobAlertModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return JobAlertModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      keywords: List<String>.from(data['keywords'] ?? []),
      location: data['location'],
      jobType: data['jobType'],
      salaryMin: data['salaryMin']?.toDouble(),
      salaryMax: data['salaryMax']?.toDouble(),
      categories: data['categories'] != null
          ? List<String>.from(data['categories'])
          : null,
      isActive: data['isActive'] ?? true,
      frequency: data['frequency'] ?? 'daily',
      createdAt: _getDateTimeFromData(data, 'createdAt') ?? DateTime.now(),
      lastTriggered: _getDateTimeFromData(data, 'lastTriggered'),
      notificationCount: data['notificationCount'] ?? 0,
      filters: data['filters'] as Map<String, dynamic>?,
    );
  }

  // Helper for JobAlertModel
  static DateTime? _getDateTimeFromData(Map<String, dynamic> data, String key) {
    if (data.containsKey(key) && data[key] != null) {
      if (data[key] is Timestamp) {
        return (data[key] as Timestamp).toDate();
      } else if (data[key] is String) {
        return DateTime.parse(data[key]);
      }
    }
    return null;
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'keywords': keywords,
      'location': location,
      'jobType': jobType,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'categories': categories,
      'isActive': isActive,
      'frequency': frequency,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastTriggered': lastTriggered != null
          ? Timestamp.fromDate(lastTriggered!)
          : null,
      'notificationCount': notificationCount,
      'filters': filters,
    };
  }

  // Convert to JSON for web storage/local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'keywords': keywords,
      'location': location,
      'jobType': jobType,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'categories': categories,
      'isActive': isActive,
      'frequency': frequency,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
      'notificationCount': notificationCount,
      'filters': filters,
    };
  }

  // Factory constructor for creating from JSON (web/local storage)
  factory JobAlertModel.fromJson(Map<String, dynamic> json) {
    return JobAlertModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
      location: json['location'],
      jobType: json['jobType'],
      salaryMin: json['salaryMin']?.toDouble(),
      salaryMax: json['salaryMax']?.toDouble(),
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
      isActive: json['isActive'] ?? true,
      frequency: json['frequency'] ?? 'daily',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      lastTriggered: json['lastTriggered'] != null
          ? DateTime.parse(json['lastTriggered'])
          : null,
      notificationCount: json['notificationCount'] ?? 0,
      filters: json['filters'] as Map<String, dynamic>?,
    );
  }

  // Create a copy with modified fields
  JobAlertModel copyWith({
    String? id,
    String? userId,
    String? title,
    List<String>? keywords,
    String? location,
    String? jobType,
    double? salaryMin,
    double? salaryMax,
    List<String>? categories,
    bool? isActive,
    String? frequency,
    DateTime? createdAt,
    DateTime? lastTriggered,
    int? notificationCount,
    Map<String, dynamic>? filters,
  }) {
    return JobAlertModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      keywords: keywords ?? this.keywords,
      location: location ?? this.location,
      jobType: jobType ?? this.jobType,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      categories: categories ?? this.categories,
      isActive: isActive ?? this.isActive,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      notificationCount: notificationCount ?? this.notificationCount,
      filters: filters ?? this.filters,
    );
  }

  // Increment notification count
  JobAlertModel incrementNotificationCount() {
    return copyWith(
      notificationCount: notificationCount + 1,
      lastTriggered: DateTime.now(),
    );
  }

  // Check if alert matches a job
  bool matchesJob(Map<String, dynamic> job) {
    // Check keywords
    if (keywords.isNotEmpty) {
      bool keywordMatch = false;
      final jobTitle = job['title']?.toString().toLowerCase() ?? '';
      final jobDescription = job['description']?.toString().toLowerCase() ?? '';
      
      for (var keyword in keywords) {
        if (jobTitle.contains(keyword.toLowerCase()) ||
            jobDescription.contains(keyword.toLowerCase())) {
          keywordMatch = true;
          break;
        }
      }
      if (!keywordMatch) return false;
    }

    // Check location
    if (location != null && location!.isNotEmpty) {
      if (job['location']?.toString().toLowerCase() != location!.toLowerCase()) {
        return false;
      }
    }

    // Check job type
    if (jobType != null && jobType!.isNotEmpty) {
      if (job['jobType']?.toString() != jobType) {
        return false;
      }
    }

    // Check salary range
    if (salaryMin != null && job['salary'] != null) {
      final jobSalary = job['salary'] is num 
          ? (job['salary'] as num).toDouble() 
          : double.tryParse(job['salary'].toString());
      
      if (jobSalary != null && jobSalary < salaryMin!) {
        return false;
      }
    }

    if (salaryMax != null && job['salary'] != null) {
      final jobSalary = job['salary'] is num 
          ? (job['salary'] as num).toDouble() 
          : double.tryParse(job['salary'].toString());
      
      if (jobSalary != null && jobSalary > salaryMax!) {
        return false;
      }
    }

    // Check categories
    if (categories != null && categories!.isNotEmpty) {
      final jobCategory = job['category']?.toString();
      if (jobCategory == null || !categories!.contains(jobCategory)) {
        return false;
      }
    }

    return true;
  }
}