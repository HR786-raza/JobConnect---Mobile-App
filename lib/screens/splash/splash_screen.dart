import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobconnect/config/routes.dart';
import 'package:jobconnect/config/app_config.dart';
import 'package:jobconnect/services/firebase_service.dart';
import 'package:jobconnect/services/notification_service.dart';
import 'package:jobconnect/providers/auth_provider.dart';
import 'package:jobconnect/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize Firebase
      await FirebaseService.initialize();

      // Initialize notifications
      await NotificationService.initialize();

      // Load user preferences
      final prefs = await SharedPreferences.getInstance();
      final bool isFirstLaunch = prefs.getBool(AppConfig.prefFirstLaunch) ?? true;
      
      // Check if user is already logged in
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;

      // Simulate minimum splash screen duration
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Navigate based on authentication and first launch status
      if (isAuthenticated) {
        // User is logged in, go to appropriate dashboard
        if (authProvider.currentUser?.userType.toString().contains('employer') ?? false) {
          Navigator.pushReplacementNamed(context, AppRoutes.employerDashboard);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.employeeDashboard);
        }
      } else if (isFirstLaunch) {
        // First time user, show onboarding
        await prefs.setBool(AppConfig.prefFirstLaunch, false);
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      } else {
        // Returning user, go to login
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Error initializing app: $e');
      
      // Show error dialog
      if (mounted) {
        _showErrorDialog();
      }
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: const Text('Failed to initialize the app. Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeApp(); // Retry initialization
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).primaryColor.withOpacity(0.6),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 3.14,
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Background circles
                                ...List.generate(3, (index) {
                                  return Positioned(
                                    child: TweenAnimationBuilder(
                                      tween: Tween<double>(begin: 0.0, end: 1.0),
                                      duration: Duration(milliseconds: 1500 + (index * 500)),
                                      curve: Curves.easeOut,
                                      builder: (context, double value, child) {
                                        return Container(
                                          width: 120 + (index * 30) * value,
                                          height: 120 + (index * 30) * value,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Theme.of(context).primaryColor.withOpacity(0.3 - (index * 0.1)),
                                              width: 2,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }),

                                // Main Icon
                                Icon(
                                  Icons.work_outline,
                                  size: 70,
                                  color: Theme.of(context).primaryColor,
                                ),

                                // Small decorative elements
                                Positioned(
                                  top: 30,
                                  right: 30,
                                  child: TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 1000),
                                    curve: Curves.elasticOut,
                                    builder: (context, double value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Container(
                                          width: 15,
                                          height: 15,
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  bottom: 30,
                                  left: 30,
                                  child: TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0.0, end: 1.0),
                                    duration: const Duration(milliseconds: 1200),
                                    curve: Curves.elasticOut,
                                    builder: (context, double value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // App Name with Animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds);
                            },
                            child: const Text(
                              AppConfig.appName,
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              AppConfig.appDescription,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Loading Indicator
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Column(
                        children: [
                          // Custom Loading Indicator
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0.0, end: 1.0),
                                  duration: const Duration(seconds: 2),
                                  curve: Curves.linear,
                                  builder: (context, double value, child) {
                                    return SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(
                                        value: value,
                                        strokeWidth: 3,
                                        backgroundColor: Colors.white.withOpacity(0.3),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    );
                                  },
                                ),
                                const Icon(
                                  Icons.rocket_launch,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Preparing your experience...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Version Info
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value * 0.7,
                      child: Text(
                        'Version ${AppConfig.appVersion}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}