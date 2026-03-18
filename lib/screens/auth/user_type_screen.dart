import 'package:flutter/material.dart';
import 'package:jobconnect/config/routes.dart';
import 'package:jobconnect/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class UserTypeScreen extends StatelessWidget {
  const UserTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo
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

              const SizedBox(height: 32),

              // Title
              const Text(
                'Welcome to JobConnect!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'How would you like to use JobConnect?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Job Seeker Card
              _buildRoleCard(
                context,
                title: 'Find a Job',
                description: 'Search for jobs, build your resume, and get AI-powered recommendations',
                icon: Icons.person_search,
                color: Colors.blue,
                onTap: () {
                  _navigateToDashboard(context, 'employee');
                },
              ),

              const SizedBox(height: 16),

              // Employer Card
              _buildRoleCard(
                context,
                title: 'Hire Talent',
                description: 'Post jobs, find candidates, and manage applications',
                icon: Icons.business_center,
                color: Colors.green,
                onTap: () {
                  _navigateToDashboard(context, 'employer');
                },
              ),

              const SizedBox(height: 32),

              // Later option
              TextButton(
                onPressed: () {
                  // Skip for now
                },
                child: const Text('I\'ll decide later'),
              ),

              const SizedBox(height: 16),

              // User info
              if (authProvider.currentUser != null)
                Column(
                  children: [
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: authProvider.currentUser!.photoURL != null
                              ? NetworkImage(authProvider.currentUser!.photoURL!)
                              : null,
                          child: authProvider.currentUser!.photoURL == null
                                ? Text(authProvider.currentUser!.email[0].toUpperCase())
                                : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.currentUser!.displayName ?? 'User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                authProvider.currentUser!.email,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Switch account
                          },
                          child: const Text('Switch'),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, String type) {
    if (type == 'employee') {
      Navigator.pushReplacementNamed(context, AppRoutes.employeeDashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.employerDashboard);
    }
  }
}