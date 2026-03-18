import 'package:flutter/material.dart';
import 'package:jobconnect/config/routes.dart';
import 'package:jobconnect/providers/auth_provider.dart' as app;  // Your custom provider with alias
import 'package:jobconnect/widgets/custom_button.dart';
import 'package:jobconnect/providers/job_provider.dart';
import 'package:jobconnect/utils/helpers.dart';
import 'package:provider/provider.dart';

// Optional: Add a typedef for convenience
typedef AppAuthProvider = app.AuthProvider;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await jobProvider.loadUserApplications(authProvider.currentUser!.uid);
      await jobProvider.loadSavedJobs(authProvider.currentUser!.uid);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context);
    final user = authProvider.currentUser;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              _showSettingsDialog();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Profile Image
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? Text(
                                  Helpers.getInitials(user?.displayName ?? 'User'),
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.editProfile);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Name
                    Text(
                      user?.displayName ?? 'User Name',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Email
                    Text(
                      user?.email ?? 'email@example.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Location
                    if (user?.location != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user!.location!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Edit Profile Button
                    CustomButton(
                      text: 'Edit Profile',
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.editProfile);
                      },
                      isOutlined: true,
                      height: 40,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Statistics Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard(
                    'Applied',
                    jobProvider.applications.length.toString(),
                    Icons.description,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    'Saved',
                    jobProvider.savedJobs.length.toString(),
                    Icons.bookmark,
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Interviews',
                    _countInterviews(jobProvider.applications).toString(),
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Skills Section
              if (user?.skills != null && user!.skills.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.code, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Skills',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.skills.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.skillsAssessment);
                          },
                          child: const Text('Update Skills'),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // About Section
              if (user?.bio != null && user!.bio!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'About',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        user.bio!,
                        style: const TextStyle(
                          height: 1.5,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Menu Items
              Card(
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.bookmark_outline,
                      title: 'Saved Jobs',
                      trailing: Text(
                        jobProvider.savedJobs.length.toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        _showSavedJobs(context, jobProvider.savedJobs);
                      },
                    ),
                    const Divider(height: 0),
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      title: 'Applied Jobs',
                      trailing: Text(
                        jobProvider.applications.length.toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        _showAppliedJobs(context, jobProvider.applications);
                      },
                    ),
                    const Divider(height: 0),
                    _buildMenuItem(
                      icon: Icons.assessment_outlined,
                      title: 'Skills Assessment',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.skillsAssessment);
                      },
                    ),
                    const Divider(height: 0),
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      title: 'Job Alerts',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.jobAlerts);
                      },
                    ),
                    const Divider(height: 0),
                    _buildMenuItem(
                      icon: Icons.chat_outlined,
                      title: 'Support Chat',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.chat);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Sign Out Button
              CustomButton(
                text: 'Sign Out',
                onPressed: _signOut,
                isOutlined: true,
                backgroundColor: Colors.red,
                textColor: Colors.red,
              ),

              const SizedBox(height: 16),

              // App Version
              const Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : null,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              trailing: const Text('English'),
              onTap: () {
                Navigator.pop(context);
                // Change language
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  Navigator.pop(context);
                  // Toggle theme
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  Navigator.pop(context);
                  // Toggle notifications
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              onTap: () {
                Navigator.pop(context);
                // Open privacy policy
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
                // Open help
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedJobs(BuildContext context, List savedJobs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Saved Jobs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (savedJobs.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No saved jobs yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Save jobs you\'re interested in',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: savedJobs.length,
                      itemBuilder: (context, index) {
                        final job = savedJobs[index];
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.work,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(job.title),
                          subtitle: Text(job.company),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              // Remove saved job
                            },
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(
                              context,
                              AppRoutes.jobDetails,
                              arguments: job,
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAppliedJobs(BuildContext context, List applications) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Applied Jobs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (applications.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No applications yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start applying to jobs',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: applications.length,
                      itemBuilder: (context, index) {
                        final app = applications[index];
                        Color statusColor;
                        switch (app.status.toString()) {
                          case 'pending':
                            statusColor = Colors.orange;
                            break;
                          case 'reviewed':
                            statusColor = Colors.blue;
                            break;
                          case 'shortlisted':
                            statusColor = Colors.green;
                            break;
                          case 'rejected':
                            statusColor = Colors.red;
                            break;
                          default:
                            statusColor = Colors.grey;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: statusColor.withOpacity(0.1),
                              child: Icon(
                                Icons.description,
                                color: statusColor,
                                size: 20,
                              ),
                            ),
                            title: Text(app.jobTitle),
                            subtitle: Text(app.employerName),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                app.statusDisplay,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              // Show application details
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _countInterviews(List applications) {
    return applications.where((app) {
      final status = app.status.toString();
      return status.contains('interview') || status.contains('shortlisted');
    }).length;
  }
}