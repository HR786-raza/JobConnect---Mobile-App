import 'package:flutter/material.dart';

// Splash Screens
import '../screens/splash/splash_screen.dart';

// Onboarding Screens
import '../screens/onboarding/onboarding_screen.dart';

// Auth Screens
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/user_type_screen.dart';

// Employee Screens
import '../screens/employee/employee_dashboard.dart';
import '../screens/employee/job_search/job_search_screen.dart';
import '../screens/employee/job_search/job_details_screen.dart';
import '../screens/employee/job_search/apply_job_screen.dart';
import '../screens/employee/resume_builder/resume_builder_screen.dart';
import '../screens/employee/skills_assessment/skills_assessment_screen.dart';
import '../screens/employee/interview_prep/interview_prep_screen.dart';
import '../screens/employee/job_alerts/job_alerts_screen.dart';
import '../screens/employee/profile/profile_screen.dart';
import '../screens/employee/profile/edit_profile_screen.dart';
import '../screens/employee/chat/chat_screen.dart';

// Employer Screens
import '../screens/employer/employer_dashboard.dart';
import '../screens/employer/job_posting/job_listing_screen.dart';
import '../screens/employer/job_posting/post_job_screen.dart';
import '../screens/employer/job_posting/job_applicants_screen.dart';
import '../screens/employer/applicants/applicant_detail_screen.dart';
import '../screens/employer/interview/interview_screen.dart';
import '../screens/employer/letter_generation/generate_letter_screen.dart';
import '../screens/employer/profile/employer_profile_screen.dart';
import '../screens/employer/profile/employer_edit_profile.dart';
import '../screens/employer/chat/employer_chat_screen.dart';

// Models
import '../models/job_model.dart';
import '../models/application_model.dart';

class AppRoutes {
  // Route Names
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String userType = '/user-type';

  // Employee Routes
  static const String employeeDashboard = '/employee-dashboard';
  static const String jobSearch = '/job-search';
  static const String jobDetails = '/job-details';
  static const String applyJob = '/apply-job';
  static const String resumeBuilder = '/resume-builder';
  static const String skillsAssessment = '/skills-assessment';
  static const String interviewPrep = '/interview-prep';
  static const String jobAlerts = '/job-alerts';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String chat = '/chat';

  // Employer Routes
  static const String employerDashboard = '/employer-dashboard';
  static const String jobListing = '/job-listing';
  static const String postJob = '/post-job';
  static const String jobApplicants = '/job-applicants';
  static const String applicantDetail = '/applicant-detail';
  static const String interview = '/interview';
  static const String generateLetter = '/generate-letter';
  static const String employerProfile = '/employer-profile';
  static const String employerEditProfile = '/employer-edit-profile';
  static const String employerChat = '/employer-chat';

  // Generate Route based on route name
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash & Onboarding
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      // Auth Routes
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case verifyEmail:
        return MaterialPageRoute(builder: (_) => const VerifyEmailScreen());
      case userType:
        return MaterialPageRoute(builder: (_) => const UserTypeScreen());

      // Employee Routes
      case employeeDashboard:
        return MaterialPageRoute(builder: (_) => const EmployeeDashboard());
      case jobSearch:
        return MaterialPageRoute(builder: (_) => const JobSearchScreen());

      // Job Details
      case jobDetails:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => JobDetailsScreen(job: args),
          );
        } else if (args is JobModel) {
          return MaterialPageRoute(
            builder: (_) => JobDetailsScreen(job: args.toFirestore()),
          );
        }
        return _errorRoute('Job details not found');

      // Apply Job
      case applyJob:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ApplyJobScreen(job: args),
          );
        } else if (args is JobModel) {
          return MaterialPageRoute(
            builder: (_) => ApplyJobScreen(job: args.toFirestore()),
          );
        }
        return _errorRoute('Job details not found');

      case resumeBuilder:
        return MaterialPageRoute(builder: (_) => const ResumeBuilderScreen());
      case skillsAssessment:
        return MaterialPageRoute(
            builder: (_) => const SkillsAssessmentScreen());
      case interviewPrep:
        return MaterialPageRoute(builder: (_) => const InterviewPrepScreen());
      case jobAlerts:
        return MaterialPageRoute(builder: (_) => const JobAlertsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());

      // Employer Routes
      case employerDashboard:
        return MaterialPageRoute(builder: (_) => const EmployerDashboard());
      case jobListing:
        return MaterialPageRoute(builder: (_) => const JobListingScreen());
      case postJob:
        return MaterialPageRoute(builder: (_) => const PostJobScreen());

      // Job Applicants
      case jobApplicants:
        final args = settings.arguments;
        return MaterialPageRoute(
          builder: (_) =>
              JobApplicantsScreen(job: args as Map<String, dynamic>?),
        );

      // Applicant Detail - FIXED
      case applicantDetail:
        final args = settings.arguments;
        if (args is ApplicationModel) {
          return MaterialPageRoute(
            builder: (_) => ApplicantDetailScreen(applicant: args),
          );
        } else if (args is Map<String, dynamic>) {
          try {
            final application = ApplicationModel.fromJson(args);
            return MaterialPageRoute(
              builder: (_) => ApplicantDetailScreen(applicant: application),
            );
          } catch (e) {
            debugPrint('Error converting to ApplicationModel: $e');
            return _errorRoute('Invalid applicant data format');
          }
        } else if (args == null) {
          return _errorRoute('No applicant data provided');
        } else {
          return _errorRoute('Invalid applicant data type');
        }

      // Interview - FIXED
      case interview:
        final args = settings.arguments;
        if (args == null) {
          return _errorRoute('Interview details not provided');
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => InterviewScreen(arguments: args),
          );
        } else if (args is ApplicationModel) {
          return MaterialPageRoute(
            builder: (_) => InterviewScreen(
              arguments: {
                'applicant': args.toJson(),
                'applicantName': args.applicantName,
                'jobTitle': args.jobTitle,
              },
            ),
          );
        } else {
          return _errorRoute('Invalid interview data');
        }

      // Generate Letter - FIXED
      case generateLetter:
        final args = settings.arguments;
        if (args == null) {
          return _errorRoute('Letter generation details not provided');
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => GenerateLetterScreen(arguments: args),
          );
        } else if (args is ApplicationModel) {
          return MaterialPageRoute(
            builder: (_) => GenerateLetterScreen(
              arguments: {
                'applicant': args.toJson(),
                'applicantName': args.applicantName,
                'jobTitle': args.jobTitle,
                'employerName': args.employerName,
              },
            ),
          );
        } else {
          return _errorRoute('Invalid letter generation data');
        }

      case employerProfile:
        return MaterialPageRoute(builder: (_) => const EmployerProfileScreen());
      case employerEditProfile:
        return MaterialPageRoute(builder: (_) => const EmployerEditProfile());
      case employerChat:
        return MaterialPageRoute(builder: (_) => const EmployerChatScreen());

      default:
        return _errorRoute('Page not found');
    }
  }

  // Error route for handling invalid routes
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigation helper methods
  static Future<T?> navigateTo<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> navigateAndReplaceTo<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> navigateAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void goBack<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  static bool canGoBack(BuildContext context) {
    return Navigator.canPop(context);
  }
}

// Navigation extension
extension NavigationExtension on BuildContext {
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return AppRoutes.navigateTo<T>(this, routeName, arguments: arguments);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return AppRoutes.navigateAndReplaceTo<T, TO>(
      this,
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return AppRoutes.navigateAndRemoveUntil<T>(
      this,
      routeName,
      arguments: arguments,
    );
  }

  void pop<T extends Object?>([T? result]) {
    AppRoutes.goBack<T>(this, result);
  }

  bool get canPop => AppRoutes.canGoBack(this);
}
