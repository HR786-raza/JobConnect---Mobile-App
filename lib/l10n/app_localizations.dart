import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'JobConnect'**
  String get app_name;

  /// Tagline for the application
  ///
  /// In en, this message translates to:
  /// **'Smart Job Portal with AI-Based Search & Filtering'**
  String get app_tagline;

  /// App version text
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Warning title
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// Information title
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get info;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get network_error;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get server_error;

  /// Unknown error message
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. Please try again.'**
  String get unknown_error;

  /// No internet connection message
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get no_internet;

  /// Retry connection button
  ///
  /// In en, this message translates to:
  /// **'Retry Connection'**
  String get retry_connection;

  /// Welcome text
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get sign_out;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password;

  /// Reset password button
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get reset_password;

  /// Create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get create_account;

  /// Already have account text
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_account;

  /// Don't have account text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dont_have_account;

  /// Google sign in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continue_with_google;

  /// Facebook sign in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continue_with_facebook;

  /// Apple sign in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continue_with_apple;

  /// OR separator
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Terms and privacy text
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service and Privacy Policy'**
  String get terms_and_privacy;

  /// User type selection title
  ///
  /// In en, this message translates to:
  /// **'Select Your Role'**
  String get select_user_type;

  /// Job seeker role
  ///
  /// In en, this message translates to:
  /// **'Job Seeker'**
  String get job_seeker;

  /// Employer role
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get employer;

  /// Find job button
  ///
  /// In en, this message translates to:
  /// **'Find a Job'**
  String get find_job;

  /// Post job button
  ///
  /// In en, this message translates to:
  /// **'Post a Job'**
  String get post_job;

  /// Search jobs title
  ///
  /// In en, this message translates to:
  /// **'Search Jobs'**
  String get search_jobs;

  /// Search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter button
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Clear filters button
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clear_filters;

  /// Apply filters button
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get apply_filters;

  /// Location field
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Salary field
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// Job type field
  ///
  /// In en, this message translates to:
  /// **'Job Type'**
  String get job_type;

  /// Experience level field
  ///
  /// In en, this message translates to:
  /// **'Experience Level'**
  String get experience_level;

  /// Full time job type
  ///
  /// In en, this message translates to:
  /// **'Full Time'**
  String get full_time;

  /// Part time job type
  ///
  /// In en, this message translates to:
  /// **'Part Time'**
  String get part_time;

  /// Internship job type
  ///
  /// In en, this message translates to:
  /// **'Internship'**
  String get internship;

  /// Contract job type
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get contract;

  /// Freelance job type
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get freelance;

  /// Remote job type
  ///
  /// In en, this message translates to:
  /// **'Remote'**
  String get remote;

  /// Entry level experience
  ///
  /// In en, this message translates to:
  /// **'Entry Level'**
  String get entry_level;

  /// Mid level experience
  ///
  /// In en, this message translates to:
  /// **'Mid Level'**
  String get mid_level;

  /// Senior level experience
  ///
  /// In en, this message translates to:
  /// **'Senior Level'**
  String get senior_level;

  /// Lead experience
  ///
  /// In en, this message translates to:
  /// **'Lead'**
  String get lead;

  /// Manager experience
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// Job title field
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get job_title;

  /// Company name
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// Description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Requirements field
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get requirements;

  /// Responsibilities field
  ///
  /// In en, this message translates to:
  /// **'Responsibilities'**
  String get responsibilities;

  /// Skills field
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// Benefits field
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get benefits;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Contact section
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Edit profile title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile;

  /// Full name field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// Phone number field
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// Bio field
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// Interests field
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get interests;

  /// Current status field
  ///
  /// In en, this message translates to:
  /// **'Current Situation'**
  String get current_status;

  /// Student status
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// Fresh graduate status
  ///
  /// In en, this message translates to:
  /// **'Fresh Graduate'**
  String get fresh_graduate;

  /// Job seeker status
  ///
  /// In en, this message translates to:
  /// **'Job Seeker'**
  String get job_seeker_status;

  /// Working professional status
  ///
  /// In en, this message translates to:
  /// **'Working Professional'**
  String get working_professional;

  /// Resume title
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// Build resume button
  ///
  /// In en, this message translates to:
  /// **'Build Resume'**
  String get build_resume;

  /// Personal info section
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personal_info;

  /// Education section
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// Experience section
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// Projects section
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// Languages section
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// Certifications section
  ///
  /// In en, this message translates to:
  /// **'Certifications'**
  String get certifications;

  /// Add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Remove button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Upload button
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// Download button
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Apply button
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Save job button
  ///
  /// In en, this message translates to:
  /// **'Save Job'**
  String get save_job;

  /// Unsave job button
  ///
  /// In en, this message translates to:
  /// **'Unsave Job'**
  String get unsave_job;

  /// Applied status
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get applied;

  /// Saved status
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// View all link
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get view_all;

  /// See all link
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get see_all;

  /// Show more link
  ///
  /// In en, this message translates to:
  /// **'Show More'**
  String get show_more;

  /// Show less link
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get show_less;

  /// No results message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get no_results;

  /// No jobs message
  ///
  /// In en, this message translates to:
  /// **'No jobs found'**
  String get no_jobs;

  /// No applications message
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get no_applications;

  /// No messages message
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get no_messages;

  /// No notifications message
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get no_notifications;

  /// No saved jobs message
  ///
  /// In en, this message translates to:
  /// **'No saved jobs'**
  String get no_saved_jobs;

  /// Start searching message
  ///
  /// In en, this message translates to:
  /// **'Start searching for your dream job'**
  String get start_searching;

  /// Featured jobs section
  ///
  /// In en, this message translates to:
  /// **'Featured Jobs'**
  String get featured_jobs;

  /// Recommended jobs section
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommended_jobs;

  /// Recent jobs section
  ///
  /// In en, this message translates to:
  /// **'Recent Jobs'**
  String get recent_jobs;

  /// Job alerts title
  ///
  /// In en, this message translates to:
  /// **'Job Alerts'**
  String get job_alerts;

  /// Create alert button
  ///
  /// In en, this message translates to:
  /// **'Create Alert'**
  String get create_alert;

  /// Alert name field
  ///
  /// In en, this message translates to:
  /// **'Alert Name'**
  String get alert_name;

  /// Frequency field
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// Daily frequency
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Weekly frequency
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Instant frequency
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get instant;

  /// Notifications title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Enable notifications button
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enable_notifications;

  /// Mark all read button
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get mark_all_read;

  /// Chat title
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Type message hint
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get type_message;

  /// Send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// AI assistant name
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get ai_assistant;

  /// Interview prep title
  ///
  /// In en, this message translates to:
  /// **'Interview Preparation'**
  String get interview_prep;

  /// Start interview button
  ///
  /// In en, this message translates to:
  /// **'Start Interview'**
  String get start_interview;

  /// Practice tab
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// Questions tab
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// Tips tab
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// Skills assessment title
  ///
  /// In en, this message translates to:
  /// **'Skills Assessment'**
  String get skills_assessment;

  /// Take assessment button
  ///
  /// In en, this message translates to:
  /// **'Take Assessment'**
  String get take_assessment;

  /// Your level text
  ///
  /// In en, this message translates to:
  /// **'Your Level'**
  String get your_level;

  /// Beginner level
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// Intermediate level
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// Advanced level
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Expert level
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get expert;

  /// Score text
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// Match percentage text
  ///
  /// In en, this message translates to:
  /// **'Match Percentage'**
  String get match_percentage;

  /// ATS score text
  ///
  /// In en, this message translates to:
  /// **'ATS Score'**
  String get ats_score;

  /// Resume analysis title
  ///
  /// In en, this message translates to:
  /// **'Resume Analysis'**
  String get resume_analysis;

  /// Suggestions title
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// Missing keywords title
  ///
  /// In en, this message translates to:
  /// **'Missing Keywords'**
  String get missing_keywords;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Settings title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Help and support
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_support;

  /// Privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;

  /// Terms of service
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_of_service;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get logout_confirmation;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get delete_confirmation;

  /// Unsaved changes warning
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Discard them?'**
  String get unsaved_changes;

  /// Permission required title
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permission_required;

  /// Camera permission message
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to take photos'**
  String get camera_permission;

  /// Gallery permission message
  ///
  /// In en, this message translates to:
  /// **'Gallery permission is required to select photos'**
  String get gallery_permission;

  /// Notification permission message
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required to receive job alerts'**
  String get notification_permission;

  /// Open settings button
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get open_settings;

  /// Not now button
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get not_now;

  /// Allow button
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// Deny button
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// Today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Days ago format
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String days_ago(int days);

  /// Hours ago format
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hours_ago(int hours);

  /// Minutes ago format
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutes_ago(int minutes);

  /// Just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get just_now;

  /// Applicants count
  ///
  /// In en, this message translates to:
  /// **'{count} applicants'**
  String applicants(int count);

  /// Saved count
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String saved_count(int count);

  /// Applications count
  ///
  /// In en, this message translates to:
  /// **'{count} applications'**
  String applications_count(int count);

  /// Matches found
  ///
  /// In en, this message translates to:
  /// **'{count} matches found'**
  String matches_found(int count);

  /// Salary range format
  ///
  /// In en, this message translates to:
  /// **'{min} - {max}'**
  String salary_range(String min, String max);

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get greeting_morning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get greeting_afternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get greeting_evening;

  /// Hello with user name
  ///
  /// In en, this message translates to:
  /// **'Hello {name}'**
  String hello_user(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
