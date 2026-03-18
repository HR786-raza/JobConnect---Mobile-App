// Remove this line - not needed
// import 'package:flutter/material.dart';

class AppConfig {
  // App Information
  static const String appName = 'JobConnect';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Smart Job Portal with AI-Based Search & Filtering';

  // Company Information
  static const String companyName = 'JobConnect Inc.';
  static const String companyEmail = 'support@jobconnect.com';
  static const String companyWebsite = 'https://www.jobconnect.com';
  static const String privacyPolicy = 'https://www.jobconnect.com/privacy';
  static const String termsOfService = 'https://www.jobconnect.com/terms';
  
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.jobconnect.com/v1',
  );
  
  // Feature Flags
  static const bool enableAIFeatures = true;
  static const bool enableChat = true;
  static const bool enableVideoInterviews = true;
  static const bool enableResumeBuilder = true;
  static const bool enableSkillsAssessment = true;
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Configuration
  static const Duration cacheDuration = Duration(hours: 1);
  static const int maxCacheSize = 50; // MB
  
  // File Upload Limits
  static const int maxResumeSize = 5 * 1024 * 1024; // 5MB
  static const int maxImageSize = 2 * 1024 * 1024; // 2MB
  static const List<String> allowedResumeFormats = ['pdf', 'doc', 'docx'];
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // AI Configuration
  static const double minimumMatchScore = 0.6;
  static const int maxJobRecommendations = 20;
  static const int interviewPrepQuestionsCount = 10;
  
  // Notification Configuration
  static const int maxNotificationsPerDay = 50;
  static const Duration notificationCooldown = Duration(minutes: 5);
  
  // Chat Configuration
  static const int maxMessageLength = 1000;
  static const int maxAttachmentSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedAttachmentTypes = [
    'image/jpeg',
    'image/png',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  ];
  
  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String isoFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
  
  // Currency
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Shared Preferences Keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefLanguage = 'language';
  static const String prefFirstLaunch = 'first_launch';
  static const String prefUserType = 'user_type';
  static const String prefOnboardingComplete = 'onboarding_complete';
  static const String prefAuthToken = 'auth_token';
  static const String prefRefreshToken = 'refresh_token';
  static const String prefUserId = 'user_id';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefBiometricEnabled = 'biometric_enabled';
  static const String prefFcmToken = 'fcm_token';
  
  // Error Messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorTimeout = 'Request timeout. Please try again.';
  static const String errorUnauthorized = 'Session expired. Please login again.';
  static const String errorForbidden = 'You don\'t have permission to perform this action.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorValidation = 'Please check your input and try again.';
  static const String errorUnknown = 'An unknown error occurred.';
  
  // Success Messages
  static const String successLogin = 'Login successful!';
  static const String successLogout = 'Logout successful!';
  static const String successRegister = 'Registration successful!';
  static const String successProfileUpdate = 'Profile updated successfully!';
  static const String successJobApplication = 'Job application submitted successfully!';
  static const String successResumeCreate = 'Resume created successfully!';
  static const String successResumeUpdate = 'Resume updated successfully!';
  
  // Warning Messages
  static const String warningUnsavedChanges = 'You have unsaved changes. Discard them?';
  static const String warningDeleteItem = 'Are you sure you want to delete this item?';
  static const String warningLogout = 'Are you sure you want to logout?';
  
  // Empty States
  static const String emptyJobs = 'No jobs found';
  static const String emptyApplications = 'No applications yet';
  static const String emptyMessages = 'No messages';
  static const String emptyNotifications = 'No notifications';
  static const String emptySavedJobs = 'No saved jobs';
  static const String emptySearchResults = 'No results found';
}