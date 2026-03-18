import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Import your providers
import '../providers/auth_provider.dart' as app;
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/job_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/notification_provider.dart';

// ============= PROVIDER EXTENSIONS =============

extension ProviderExtension on BuildContext {
  app.AuthProvider get auth => Provider.of<app.AuthProvider>(this, listen: false);
  ThemeProvider get theme => Provider.of<ThemeProvider>(this, listen: false);
  LocaleProvider get locale => Provider.of<LocaleProvider>(this, listen: false);
  JobProvider get job => Provider.of<JobProvider>(this, listen: false);
  ChatProvider get chat => Provider.of<ChatProvider>(this, listen: false);
  NotificationProvider get notifications => Provider.of<NotificationProvider>(this, listen: false);
}

// ============= SCREEN SIZE EXTENSIONS =============

extension ScreenSizeExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double get screenShortestSide => MediaQuery.of(this).size.shortestSide;
  double get screenLongestSide => MediaQuery.of(this).size.longestSide;

  bool get isSmallScreen => screenShortestSide < 600;
  bool get isMediumScreen => screenShortestSide >= 600 && screenShortestSide < 900;
  bool get isLargeScreen => screenShortestSide >= 900;

  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;
  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  bool get isWeb => kIsWeb;
  bool get isMobile => !kIsWeb;
}

// ============= THEME EXTENSIONS =============

extension ThemeExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get primaryColor => Theme.of(this).primaryColor;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}

// ============= NAVIGATION EXTENSIONS =============

extension NavigationExtension on BuildContext {
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(this, routeName, arguments: arguments);
  }

  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      this,
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      this,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  void pop<T extends Object?>([T? result]) {
    Navigator.pop(this, result);
  }

  bool get canPop => Navigator.canPop(this);
}

// ============= SNACKBAR EXTENSIONS =============

extension SnackBarExtension on BuildContext {
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showInfoSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showWarningSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void hideCurrentSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }

  void clearSnackBars() {
    ScaffoldMessenger.of(this).clearSnackBars();
  }
}