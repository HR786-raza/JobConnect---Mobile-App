import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { employee, employer }

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final UserType userType;
  final String? phoneNumber;
  final String? location;
  final String? bio;
  final List<String> skills;
  final List<String> interests;
  final Map<String, dynamic>? companyDetails;
  final DateTime createdAt;
  final DateTime lastActive;
  final bool isEmailVerified;
  final Map<String, dynamic>? socialLinks;
  final List<String> savedJobs;
  final List<String> appliedJobs;
  final NotificationSettings notificationSettings;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.userType,
    this.phoneNumber,
    this.location,
    this.bio,
    this.skills = const [],
    this.interests = const [],
    this.companyDetails,
    required this.createdAt,
    required this.lastActive,
    this.isEmailVerified = false,
    this.socialLinks,
    this.savedJobs = const [],
    this.appliedJobs = const [],
    this.notificationSettings = const NotificationSettings(),
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      userType: data['userType'] == 'employer' ? UserType.employer : UserType.employee,
      phoneNumber: data['phoneNumber'],
      location: data['location'],
      bio: data['bio'],
      skills: List<String>.from(data['skills'] ?? []),
      interests: List<String>.from(data['interests'] ?? []),
      companyDetails: data['companyDetails'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastActive: (data['lastActive'] as Timestamp).toDate(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      socialLinks: data['socialLinks'],
      savedJobs: List<String>.from(data['savedJobs'] ?? []),
      appliedJobs: List<String>.from(data['appliedJobs'] ?? []),
      notificationSettings: NotificationSettings.fromMap(data['notificationSettings']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'userType': userType == UserType.employer ? 'employer' : 'employee',
      'phoneNumber': phoneNumber,
      'location': location,
      'bio': bio,
      'skills': skills,
      'interests': interests,
      'companyDetails': companyDetails,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
      'isEmailVerified': isEmailVerified,
      'socialLinks': socialLinks,
      'savedJobs': savedJobs,
      'appliedJobs': appliedJobs,
      'notificationSettings': notificationSettings.toMap(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    UserType? userType,
    String? phoneNumber,
    String? location,
    String? bio,
    List<String>? skills,
    List<String>? interests,
    Map<String, dynamic>? companyDetails,
    DateTime? createdAt,
    DateTime? lastActive,
    bool? isEmailVerified,
    Map<String, dynamic>? socialLinks,
    List<String>? savedJobs,
    List<String>? appliedJobs,
    NotificationSettings? notificationSettings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      userType: userType ?? this.userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
      companyDetails: companyDetails ?? this.companyDetails,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      socialLinks: socialLinks ?? this.socialLinks,
      savedJobs: savedJobs ?? this.savedJobs,
      appliedJobs: appliedJobs ?? this.appliedJobs,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
}

class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool jobAlerts;
  final bool applicationUpdates;
  final bool messageNotifications;
  final bool interviewReminders;
  final String alertFrequency; // daily, weekly, instant

  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.jobAlerts = true,
    this.applicationUpdates = true,
    this.messageNotifications = true,
    this.interviewReminders = true,
    this.alertFrequency = 'instant',
  });

  factory NotificationSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NotificationSettings();
    
    return NotificationSettings(
      pushEnabled: map['pushEnabled'] ?? true,
      emailEnabled: map['emailEnabled'] ?? true,
      jobAlerts: map['jobAlerts'] ?? true,
      applicationUpdates: map['applicationUpdates'] ?? true,
      messageNotifications: map['messageNotifications'] ?? true,
      interviewReminders: map['interviewReminders'] ?? true,
      alertFrequency: map['alertFrequency'] ?? 'instant',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'jobAlerts': jobAlerts,
      'applicationUpdates': applicationUpdates,
      'messageNotifications': messageNotifications,
      'interviewReminders': interviewReminders,
      'alertFrequency': alertFrequency,
    };
  }

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? jobAlerts,
    bool? applicationUpdates,
    bool? messageNotifications,
    bool? interviewReminders,
    String? alertFrequency,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      jobAlerts: jobAlerts ?? this.jobAlerts,
      applicationUpdates: applicationUpdates ?? this.applicationUpdates,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      interviewReminders: interviewReminders ?? this.interviewReminders,
      alertFrequency: alertFrequency ?? this.alertFrequency,
    );
  }
}