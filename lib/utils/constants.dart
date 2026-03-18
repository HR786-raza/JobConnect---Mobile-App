class AppConstants {
  // App Information
  static const String appName = 'JobConnect';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Smart Job Portal with AI-Based Search & Filtering';
  
  // API Endpoints
  static const String baseUrl = 'https://api.jobconnect.com/v1';
  static const String aiMatchingEndpoint = '$baseUrl/ai/match';
  static const String interviewPrepEndpoint = '$baseUrl/ai/interview';
  static const String resumeAnalysisEndpoint = '$baseUrl/ai/analyze-resume';
  
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
  static const String prefFCMToken = 'fcm_token';
  
  // Collection Names
  static const String usersCollection = 'users';
  static const String jobsCollection = 'jobs';
  static const String applicationsCollection = 'applications';
  static const String resumesCollection = 'resumes';
  static const String messagesCollection = 'messages';
  static const String conversationsCollection = 'conversations';
  static const String notificationsCollection = 'notifications';
  static const String companiesCollection = 'companies';
  static const String assessmentsCollection = 'assessments';
  static const String templatesCollection = 'templates';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String resumesPath = 'resumes';
  static const String companyLogosPath = 'company_logos';
  static const String jobAttachmentsPath = 'job_attachments';
  static const String chatAttachmentsPath = 'chat_attachments';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Duration
  static const int cacheDurationHours = 1;
  static const int maxCacheSizeMB = 50;
  
  // File Upload Limits
  static const int maxResumeSizeMB = 5;
  static const int maxImageSizeMB = 2;
  static const int maxAttachmentSizeMB = 10;
  
  // Allowed File Formats
  static const List<String> allowedResumeFormats = ['pdf', 'doc', 'docx'];
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedAttachmentTypes = [
    'image/jpeg',
    'image/png',
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  ];
  
  // Timeouts
  static const int connectionTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int sendTimeoutSeconds = 30;
  
  // AI Configuration
  static const double minimumMatchScore = 0.6;
  static const int maxJobRecommendations = 20;
  static const int interviewPrepQuestionsCount = 10;
  static const int skillsAssessmentQuestionsCount = 15;
  
  // Notification Configuration
  static const int maxNotificationsPerDay = 50;
  static const int notificationCooldownMinutes = 5;
  
  // Chat Configuration
  static const int maxMessageLength = 1000;
  static const int maxAttachmentSize = 10 * 1024 * 1024; // 10MB
  
  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String isoFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'h:mm a';
  static const String displayDateTimeFormat = 'MMM dd, yyyy • h:mm a';
  
  // Currency
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;
  static const int maxJobTitleLength = 100;
  static const int maxCompanyNameLength = 100;
  static const int maxLocationLength = 100;
  
  // Animation Durations (in milliseconds)
  static const int shortAnimationMs = 200;
  static const int mediumAnimationMs = 400;
  static const int longAnimationMs = 600;
  
  // Error Messages
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorServer = 'Server error. Please try again later.';
  static const String errorTimeout = 'Request timeout. Please try again.';
  static const String errorUnauthorized = 'Session expired. Please login again.';
  static const String errorForbidden = 'You don\'t have permission to perform this action.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorValidation = 'Please check your input and try again.';
  static const String errorUnknown = 'An unknown error occurred.';
  static const String errorInvalidEmail = 'Please enter a valid email address.';
  static const String errorWeakPassword = 'Password must be at least 8 characters.';
  static const String errorPasswordsNotMatch = 'Passwords do not match.';
  static const String errorRequired = 'This field is required.';
  
  // Success Messages
  static const String successLogin = 'Login successful!';
  static const String successLogout = 'Logout successful!';
  static const String successRegister = 'Registration successful!';
  static const String successProfileUpdate = 'Profile updated successfully!';
  static const String successJobApplication = 'Job application submitted successfully!';
  static const String successResumeCreate = 'Resume created successfully!';
  static const String successResumeUpdate = 'Resume updated successfully!';
  static const String successJobPost = 'Job posted successfully!';
  static const String successMessageSent = 'Message sent successfully!';
  static const String successPasswordReset = 'Password reset email sent!';
  
  // Warning Messages
  static const String warningUnsavedChanges = 'You have unsaved changes. Discard them?';
  static const String warningDeleteItem = 'Are you sure you want to delete this item?';
  static const String warningLogout = 'Are you sure you want to logout?';
  static const String warningDeleteAccount = 'This action cannot be undone. Delete account?';
  
  // Empty States
  static const String emptyJobs = 'No jobs found';
  static const String emptyApplications = 'No applications yet';
  static const String emptyMessages = 'No messages';
  static const String emptyNotifications = 'No notifications';
  static const String emptySavedJobs = 'No saved jobs';
  static const String emptySearchResults = 'No results found';
  static const String emptyConversations = 'No conversations yet';
  static const String emptyResumes = 'No resumes created';
  
  // Job Types
  static const List<String> jobTypes = [
    'Full Time',
    'Part Time',
    'Internship',
    'Contract',
    'Freelance',
    'Remote',
  ];
  
  // Experience Levels
  static const List<String> experienceLevels = [
    'Entry Level',
    'Mid Level',
    'Senior Level',
    'Lead',
    'Manager',
    'Director',
  ];
  
  // Skills Categories
  static const Map<String, List<String>> skillCategories = {
    'Programming Languages': ['Python', 'Java', 'JavaScript', 'C++', 'Swift', 'Kotlin', 'Dart', 'Go', 'Rust'],
    'Frameworks': ['Flutter', 'React', 'Angular', 'Vue', 'Django', 'Spring Boot', 'Node.js'],
    'Databases': ['MySQL', 'PostgreSQL', 'MongoDB', 'Firebase', 'Redis', 'Elasticsearch'],
    'Cloud': ['AWS', 'Azure', 'Google Cloud', 'Docker', 'Kubernetes', 'Terraform'],
    'Mobile': ['iOS', 'Android', 'React Native', 'Flutter', 'Xamarin'],
    'UI/UX': ['Figma', 'Adobe XD', 'Sketch', 'Photoshop', 'Illustrator'],
    'Soft Skills': ['Communication', 'Leadership', 'Problem Solving', 'Teamwork', 'Time Management'],
  };
}