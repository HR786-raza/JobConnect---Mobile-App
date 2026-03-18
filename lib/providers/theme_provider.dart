import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  // Load saved theme mode
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedThemeMode = prefs.getString(AppConfig.prefThemeMode) ?? 'system';
      
      switch (savedThemeMode) {
        case 'light':
          _themeMode = ThemeMode.light;
          _isDarkMode = false;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          _isDarkMode = true;
          break;
        default:
          _themeMode = ThemeMode.system;
          // FIXED: Use WidgetsBinding.instance instead of WidgetsBinding
          _isDarkMode = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
          break;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _themeMode = mode;
      
      // Update isDarkMode based on selection
      switch (mode) {
        case ThemeMode.light:
          _isDarkMode = false;
          break;
        case ThemeMode.dark:
          _isDarkMode = true;
          break;
        case ThemeMode.system:
          // FIXED: Use WidgetsBinding.instance
          _isDarkMode = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
          break;
      }

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      String modeString = 'system';
      if (mode == ThemeMode.light) modeString = 'light';
      if (mode == ThemeMode.dark) modeString = 'dark';
      
      await prefs.setString(AppConfig.prefThemeMode, modeString);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting theme mode: $e');
    }
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system, check current brightness and toggle accordingly
      // FIXED: Use WidgetsBinding.instance
      final isDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
      await setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
    }
  }

  // Get current theme brightness
  Brightness get brightness => _isDarkMode ? Brightness.dark : Brightness.light;

  // Check if dark mode is enabled
  bool get isDarkModeEnabled => _isDarkMode;

  // Reset to system default
  Future<void> resetToSystem() async {
    await setThemeMode(ThemeMode.system);
  }

  // FIXED: Added method to update system theme when it changes
  void onPlatformBrightnessChanged() {
    if (_themeMode == ThemeMode.system) {
      _isDarkMode = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
      notifyListeners();
    }
  }
}