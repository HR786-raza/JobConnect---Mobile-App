import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jobconnect/config/routes.dart';
// import 'package:jobconnect/config/app_config.dart';
import 'package:jobconnect/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      title: 'Find Your Dream Job',
      description: 'Discover thousands of job opportunities tailored to your skills and preferences. Search by location, industry, or job type.',
      icon: Icons.search,
      color: Colors.blue,
      imageUrl: 'assets/images/onboarding1.png',
    ),
    OnboardingItem(
      title: 'AI Job Matching',
      description: 'Get personalized job recommendations based on your profile, skills, and experience. Our AI finds the best matches for you.',
      icon: Icons.auto_awesome,
      color: Colors.purple,
      imageUrl: 'assets/images/onboarding2.png',
    ),
    OnboardingItem(
      title: 'Build Professional Resume',
      description: 'Create ATS-friendly resumes that stand out to employers. Use our AI-powered builder to craft the perfect resume.',
      icon: Icons.description,
      color: Colors.green,
      imageUrl: 'assets/images/onboarding3.png',
    ),
    OnboardingItem(
      title: 'Track Applications',
      description: 'Keep track of all your job applications in one place. Get real-time updates on application status.',
      icon: Icons.track_changes,
      color: Colors.orange,
      imageUrl: 'assets/images/onboarding4.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Colors.white,
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (hidden on first page)
                      if (_currentPage > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: _previousPage,
                        )
                      else
                        const SizedBox(width: 48),

                      // Skip button (hidden on last page)
                      if (_currentPage < _onboardingItems.length - 1)
                        TextButton(
                          onPressed: _completeOnboarding,
                          child: const Text(
                            'Skip',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingItems.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                      _animationController.reset();
                      _animationController.forward();
                    },
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildOnboardingPage(_onboardingItems[index]),
                          );
                        },
                      );
                    },
                  ),
                ),

                // Page indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingItems.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),
                ),

                // Next/Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: CustomButton(
                    text: _currentPage == _onboardingItems.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: _nextPage,
                    icon: _currentPage == _onboardingItems.length - 1
                        ? Icons.check
                        : Icons.arrow_forward,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulsing circles
                      ...List.generate(3, (i) {
                        return TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 1500 + (i * 500)),
                          curve: Curves.easeOut,
                          builder: (context, double value, child) {
                            return Container(
                              width: 180 + (i * 40) * value,
                              height: 180 + (i * 40) * value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: item.color.withOpacity(0.2 - (i * 0.05)),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        );
                      }),

                      // Main icon
                      Icon(
                        item.icon,
                        size: 80,
                        color: item.color,
                      ),

                      // Small decorative elements
                      Positioned(
                        top: 40,
                        right: 40,
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 40,
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1000),
                          curve: Curves.elasticOut,
                          builder: (context, double value, child) {
                            return Opacity(
                              opacity: value,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: item.color,
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
              );
            },
          ),

          const SizedBox(height: 48),

          // Title
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Description
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // Feature highlights
          if (item.features != null)
            ...item.features!.map((feature) => _buildFeatureItem(feature)),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).primaryColor
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? imageUrl;
  final List<String>? features;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.imageUrl,
    this.features,
  });
}