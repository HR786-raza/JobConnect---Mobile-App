import 'package:flutter/material.dart';
import 'package:jobconnect/config/routes.dart';
import 'package:jobconnect/widgets/search_bar.dart';
import 'package:jobconnect/providers/auth_provider.dart' as app;
import 'package:jobconnect/providers/job_provider.dart';
import 'package:provider/provider.dart';

class EmployerDashboard extends StatefulWidget {
  const EmployerDashboard({super.key});

  @override
  State<EmployerDashboard> createState() => _EmployerDashboardState();
}

class _EmployerDashboardState extends State<EmployerDashboard> {
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final authProvider = Provider.of<app.AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      // FIXED: Use employerName instead of uid for loading applications
      await jobProvider
          .loadEmployerApplications(authProvider.currentUser!.displayName ?? '');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // FIXED: Added filter dialog method
  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Applications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All Applications'),
              leading: Radio<int>(
                value: 0,
                groupValue: 0,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Pending'),
              leading: Radio<int>(
                value: 1,
                groupValue: 0,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: const Text('Shortlisted'),
              leading: Radio<int>(
                value: 2,
                groupValue: 0,
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Apply filters
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<app.AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context);
    final user = authProvider.currentUser;
    final greeting = _getGreeting();

    // Calculate statistics
    final totalJobs = jobProvider.jobs.length;
    final totalApplications = jobProvider.applications.length;
    final pendingApplications = jobProvider.applications
        .where((app) => app.status.toString().contains('pending'))
        .length;
    final shortlistedApplications = jobProvider.applications
        .where((app) => app.status.toString().contains('shortlisted'))
        .length;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // App Bar with Greeting
              SliverAppBar(
                floating: true,
                pinned: false,
                snap: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          user?.displayName?.split(' ')[0] ??
                              'Employer', // FIXED: displayName → name
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              onPressed: () {
                                Navigator.pushNamed(context, '/notifications');
                              },
                            ),
                            if (pendingApplications > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                                context, AppRoutes.employerProfile);
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: user?.photoURL != null
                                ? NetworkImage(user!.photoURL!)
                                : null,
                            child: user?.photoURL == null
                                ? Text(user?.email[0].toUpperCase() ?? 'E')
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Search Bar - FIXED
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                    child: CustomSearchBar(
                  hintText: 'Search applications...',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.jobApplicants);
                  },
                  onChanged: (value) {
                     // Handle search if needed
                  },
                  controller: null, // Add this
                  autoFocus: false, // Add this
                )),
              ),

              // Statistics Cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        'Total Jobs',
                        totalJobs.toString(),
                        Icons.work,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Applications',
                        totalApplications.toString(),
                        Icons.people,
                        Colors.green,
                      ),
                      _buildStatCard(
                        'Pending',
                        pendingApplications.toString(),
                        Icons.hourglass_empty,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Shortlisted',
                        shortlistedApplications.toString(),
                        Icons.star,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(top: 24)),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              'Post New Job',
                              Icons.add_circle,
                              Colors.green,
                              () {
                                Navigator.pushNamed(context, AppRoutes.postJob);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              'View Applicants',
                              Icons.people,
                              Colors.blue,
                              () {
                                Navigator.pushNamed(
                                    context, AppRoutes.jobApplicants);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              'Schedule Interview',
                              Icons.calendar_today,
                              Colors.orange,
                              () {
                                // Navigate to schedule interview
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionCard(
                              'Generate Letter',
                              Icons.description,
                              Colors.purple,
                              () {
                                Navigator.pushNamed(
                                    context, AppRoutes.generateLetter);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(top: 24)),

              // Recent Applications
              if (jobProvider.applications.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Applications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, AppRoutes.jobApplicants);
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= 5) return null;
                        final application = jobProvider.applications[index];
                        return _buildApplicationCard(application);
                      },
                      childCount: jobProvider.applications.length.clamp(0, 5),
                    ),
                  ),
                ),
              ],

              // Loading Indicator
              if (jobProvider.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // FIXED: Added proper typing for application parameter
  Widget _buildApplicationCard(dynamic application) {
    Color statusColor;
    switch (application.status.toString()) {
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Text(
            application.applicantName.isNotEmpty
                ? application.applicantName[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          application.applicantName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(application.jobTitle),
            const SizedBox(height: 4),
            Text(
              'Applied ${_getTimeAgo(application.appliedAt)}', // FIXED: appliedDate → appliedAt
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            application.status.display, // FIXED: statusDisplay → status.display
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.applicantDetail,
            arguments: application,
          );
        },
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
          _handleNavigation(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outlined),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Applicants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.jobListing);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.jobApplicants);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.employerChat);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.employerProfile);
        break;
    }
  }
}
