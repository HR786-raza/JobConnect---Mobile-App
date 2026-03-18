import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobconnect/config/routes.dart';
import 'package:jobconnect/widgets/custom_button.dart';
import 'package:jobconnect/services/auth_service.dart';
import 'package:jobconnect/utils/validators.dart';
import 'package:jobconnect/utils/permission_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle email sign in
  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null && mounted) {
        // Request notification permissions after successful login
        await PermissionHelper.checkAndRequestPermission(
          permission: Permission.notification,
          permissionName: 'Notifications',
          feature: 'receiving job alerts',
          context: context,
        );

        Navigator.pushReplacementNamed(context, AppRoutes.userType);
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No user found with this email';
            break;
          case 'wrong-password':
            _errorMessage = 'Wrong password';
            break;
          case 'invalid-email':
            _errorMessage = 'Invalid email address';
            break;
          case 'user-disabled':
            _errorMessage = 'This account has been disabled';
            break;
          default:
            _errorMessage = 'Login failed: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle Google sign in
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        // Request notification permissions after successful login
        await PermissionHelper.checkAndRequestPermission(
          permission: Permission.notification,
          permissionName: 'Notifications',
          feature: 'receiving job alerts',
          context: context,
        );

        Navigator.pushReplacementNamed(context, AppRoutes.userType);
      } else {
        setState(() {
          _errorMessage = 'Google sign in cancelled';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Google sign in failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Handle Facebook sign in
  Future<void> _handleFacebookSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.signInWithFacebook();

      if (user != null && mounted) {
        // Request notification permissions after successful login
        await PermissionHelper.checkAndRequestPermission(
          permission: Permission.notification,
          permissionName: 'Notifications',
          feature: 'receiving job alerts',
          context: context,
        );

        Navigator.pushReplacementNamed(context, AppRoutes.userType);
      } else {
        setState(() {
          _errorMessage = 'Facebook sign in cancelled';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Facebook sign in failed. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Navigate to forgot password
  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  // Navigate to register
  void _navigateToRegister() {
    Navigator.pushNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              
              // Logo and App Name
              Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.work_outline,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'JobConnect',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find your dream job with AI',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Email/Password Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorMaxLines: 2,
                      ),
                      validator: Validators.validateEmail,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorMaxLines: 2,
                      ),
                      validator: Validators.validatePassword,
                      enabled: !_isLoading,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _navigateToForgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ),

              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Sign In Button
              CustomButton(
                text: 'Sign In',
                onPressed: _isLoading ? () {} : _handleEmailSignIn,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 24),

              // OR Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),

              const SizedBox(height: 24),

              // Google Sign In
              CustomButton(
                text: 'Continue with Google',
                onPressed: _isLoading ? () {} : _handleGoogleSignIn,
                icon: Icons.g_mobiledata,
                isOutlined: true,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 12),

              // Facebook Sign In
              CustomButton(
                text: 'Continue with Facebook',
                onPressed: _isLoading ? () {} : _handleFacebookSignIn,
                icon: Icons.facebook,
                isOutlined: true,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 32),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _navigateToRegister,
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Terms and Privacy
              Text(
                'By continuing, you agree to our Terms of Service and Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}