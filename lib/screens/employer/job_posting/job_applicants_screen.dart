import 'package:flutter/material.dart';
import 'package:jobconnect/config/routes.dart';
import 'package:jobconnect/widgets/custom_button.dart';
import 'package:jobconnect/widgets/search_bar.dart';
import 'package:jobconnect/providers/job_provider.dart';
import 'package:jobconnect/providers/auth_provider.dart'
    as app; // FIXED: Aliased import
import 'package:jobconnect/models/application_model.dart';
import 'package:provider/provider.dart';

class JobApplicantsScreen extends StatefulWidget {
  final Map<String, dynamic>? job;

  const JobApplicantsScreen({super.key, this.job});

  @override
  State<JobApplicantsScreen> createState() => _JobApplicantsScreenState();
}

class _JobApplicantsScreenState extends State<JobApplicantsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filters = [
    'All',
    'Pending',
    'Reviewed',
    'Shortlisted',
    'Rejected',
    'Interview',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);
    final authProvider = Provider.of<app.AuthProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      // FIXED: Use employerName (company name) instead of uid
      await jobProvider
          .loadEmployerApplications(authProvider.currentUser!.displayName ?? '');
    }
  }

  List<ApplicationModel> get _filteredApplications {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    return jobProvider.applications.where((app) {
      // Filter by job if specific job is selected
      if (widget.job != null && app.jobId != widget.job!['id']) {
        return false;
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!app.applicantName.toLowerCase().contains(query) &&
            !app.jobTitle.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Apply status filter
      if (_selectedFilter != 'All') {
        final filterLower = _selectedFilter.toLowerCase();
        final statusLower = app.status.toString().split('.').last.toLowerCase();

        if (_selectedFilter == 'Interview') {
          // Special handling for Interview filter
          if (app.status != ApplicationStatus.interviewScheduled &&
              app.status != ApplicationStatus.interviewCompleted) {
            return false;
          }
        } else if (!statusLower.contains(filterLower)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Map<String, List<ApplicationModel>> get _groupedApplications {
    final all = _filteredApplications;
    return {
      'all': all,
      'pending':
          all.where((app) => app.status == ApplicationStatus.pending).toList(),
      'reviewed':
          all.where((app) => app.status == ApplicationStatus.reviewed).toList(),
      'shortlisted': all
          .where((app) => app.status == ApplicationStatus.shortlisted)
          .toList(),
      'rejected':
          all.where((app) => app.status == ApplicationStatus.rejected).toList(),
      'interview': all
          .where((app) =>
              app.status == ApplicationStatus.interviewScheduled ||
              app.status == ApplicationStatus.interviewCompleted)
          .toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job != null
            ? 'Applicants for ${widget.job!['title']}'
            : 'Job Applicants'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.people)),
            Tab(text: 'Shortlisted', icon: Icon(Icons.star)),
            Tab(text: 'Interview', icon: Icon(Icons.calendar_today)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Field
                CustomSearchBar(
                  hintText: 'Search applicants by name or job...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  controller: null,
                  autoFocus: false,
                ),
                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Stats Summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredApplications.length} applicants found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Row(
                  children: [
                    _buildStatBadge('Pending',
                        _groupedApplications['pending']!.length, Colors.orange),
                    const SizedBox(width: 8),
                    _buildStatBadge(
                        'Shortlisted',
                        _groupedApplications['shortlisted']!.length,
                        Colors.green),
                  ],
                ),
              ],
            ),
          ),

          // Applicants List
          Expanded(
            child: jobProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredApplications.isEmpty
                    ? _buildEmptyState()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // All Applicants Tab
                          _buildApplicantsList(_groupedApplications['all']!),

                          // Shortlisted Tab
                          _groupedApplications['shortlisted']!.isEmpty
                              ? _buildEmptyState(
                                  'No shortlisted applicants yet')
                              : _buildApplicantsList(
                                  _groupedApplications['shortlisted']!),

                          // Interview Tab
                          _groupedApplications['interview']!.isEmpty
                              ? _buildEmptyState('No interview scheduled')
                              : _buildApplicantsList(
                                  _groupedApplications['interview']!),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  // FIXED: Added filter dialog method
  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Applicants'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Additional filter options will be added here.'),
            // Add more filter options as needed
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
              // Apply additional filters
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantsList(List<ApplicationModel> applicants) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: applicants.length,
      itemBuilder: (context, index) {
        final application = applicants[index];
        return _buildApplicantCard(application);
      },
    );
  }

  Widget _buildApplicantCard(ApplicationModel application) {
    final statusColor = ApplicationStatusColors.getColor(application.status);
    final statusIcon = ApplicationStatusColors.getIcon(application.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.applicantDetail,
            arguments: application,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Text(
                      application.applicantName.isNotEmpty
                          ? application.applicantName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Applicant Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.applicantName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.jobTitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getTimeAgo(application
                                  .appliedAt), // FIXED: appliedDate → appliedAt
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Match Score (if available)
                  if (application.matchScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: Colors.green,
                            size: 14,
                          ),
                          Text(
                            '${application.matchScore!.round()}%',
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Status and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          application.status
                              .display, // FIXED: statusDisplay → status.display
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      if (application.status == ApplicationStatus.pending)
                        TextButton(
                          onPressed: () => _updateStatus(
                              application.id, ApplicationStatus.reviewed),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            minimumSize: const Size(40, 30),
                          ),
                          child: const Text('Review'),
                        ),
                      if (application.status == ApplicationStatus.reviewed) ...[
                        TextButton(
                          onPressed: () => _updateStatus(
                              application.id, ApplicationStatus.shortlisted),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green,
                            minimumSize: const Size(40, 30),
                          ),
                          child: const Text('Shortlist'),
                        ),
                        TextButton(
                          onPressed: () => _updateStatus(
                              application.id, ApplicationStatus.rejected),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            minimumSize: const Size(40, 30),
                          ),
                          child: const Text('Reject'),
                        ),
                      ],
                      if (application.status == ApplicationStatus.shortlisted)
                        TextButton(
                          onPressed: () => _scheduleInterview(application),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.purple,
                            minimumSize: const Size(40, 30),
                          ),
                          child: const Text('Interview'),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Skills Preview
              if (application.aiAnalysis != null &&
                  application.aiAnalysis!['skills'] != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: (application.aiAnalysis!['skills'] as List)
                        .take(3)
                        .map<Widget>((skill) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          skill.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(
      String applicationId, ApplicationStatus status) async {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    await jobProvider.updateApplicationStatus(applicationId, status);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application ${status.display}'),
          backgroundColor: ApplicationStatusColors.getColor(status),
        ),
      );
    }
  }

  Future<void> _scheduleInterview(ApplicationModel application) async {
    // Navigate to schedule interview screen
    Navigator.pushNamed(
      context,
      AppRoutes.interview,
      arguments: {
        'applicant': application.toJson(),
        'job': {'title': application.jobTitle},
      },
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

  Widget _buildEmptyState([String message = 'No applicants found']) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          if (widget.job != null) ...[
            const SizedBox(height: 8),
            Text(
              'Share this job to get applications',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Share Job',
              onPressed: () {
                // Share job
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing feature coming soon')),
                );
              },
              width: 200,
            ),
          ],
        ],
      ),
    );
  }
}
