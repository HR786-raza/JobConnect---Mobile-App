import 'package:flutter/material.dart';
import 'package:jobconnect/config/routes.dart';
import 'package:jobconnect/widgets/custom_button.dart';
import 'package:jobconnect/services/auth_service.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isVerified = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _checkVerification();
  }

  // Check email verification status
  Future<void> _checkVerification() async {
    await _authService.refreshUser();
    
    if (_authService.isEmailVerified && mounted) {
      setState(() {
        _isVerified = true;
      });
      
      // Navigate after short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.userType);
        }
      });
    }
  }

  // Resend verification email
  Future<void> _resendVerification() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _authService.sendEmailVerification();
      setState(() {
        _message = 'Verification email sent! Check your inbox.';
      });
    } catch (e) {
      setState(() {
        _message = 'Failed to send verification email. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isVerified) ...[
                // Success state
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Email Verified!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your email has been successfully verified.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Redirecting you to dashboard...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ] else ...[
                // Verification pending state
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread,
                    color: Colors.orange,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ve sent a verification email to:\n${_authService.currentUser?.email}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Please check your email and click the verification link to complete your registration.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Message
                if (_message != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _message!.contains('Failed')
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _message!.contains('Failed')
                            ? Colors.red
                            : Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 16),

                // Resend Button
                CustomButton(
                  text: 'Resend Verification Email',
                  onPressed: _isLoading ? () {} : () => _resendVerification(),
                  isLoading: _isLoading,
                ),

                const SizedBox(height: 12),

                // Check Again Button
                CustomButton(
                  text: 'I\'ve Verified',
                  onPressed: _checkVerification,
                  isOutlined: true,
                ),

                const SizedBox(height: 24),

                // Logout Option
                TextButton(
                  onPressed: () async {
                    await _authService.signOut();
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                  child: const Text('Use a different account'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}