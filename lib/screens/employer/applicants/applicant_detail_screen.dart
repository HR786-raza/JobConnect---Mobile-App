import 'package:flutter/material.dart';
import 'package:jobconnect/config/routes.dart';
import 'package:jobconnect/widgets/custom_button.dart';
import 'package:jobconnect/widgets/skill_chip.dart';
import 'package:jobconnect/models/application_model.dart';
import 'package:jobconnect/services/ai_service.dart';

class ApplicantDetailScreen extends StatefulWidget {
  final ApplicationModel applicant;

  const ApplicantDetailScreen({super.key, required this.applicant});

  @override
  State<ApplicantDetailScreen> createState() => _ApplicantDetailScreenState();
}

class _ApplicantDetailScreenState extends State<ApplicantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _resumeAnalysis;
  List<Map<String, dynamic>> _interviewQuestions = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _analyzeResume();
    _loadInterviewQuestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _analyzeResume() async {
    setState(() {
      _isAnalyzing = true;
    });

    // Simulate AI analysis
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isAnalyzing = false;
      _resumeAnalysis = {
        'overallScore': 85,
        'keywordsScore': 78,
        'formattingScore': 92,
        'lengthScore': 88,
        'missingKeywords': [
          'Leadership',
          'Agile',
          'Scrum',
          'Project Management'
        ],
        'suggestions': [
          'Add more quantifiable achievements',
          'Include leadership experience',
          'Add a professional summary',
          'Highlight technical skills more prominently',
        ],
        'skills': ['Flutter', 'Dart', 'Firebase', 'REST APIs', 'Git', 'UI/UX'],
        'experience': [
          {
            'company': 'Tech Corp',
            'role': 'Flutter Developer',
            'duration': '2022-Present'
          },
          {
            'company': 'StartUp Inc',
            'role': 'Junior Developer',
            'duration': '2020-2022'
          },
        ],
        'education': [
          {
            'degree': 'BSc Computer Science',
            'institution': 'University of Tech',
            'year': '2020'
          },
        ],
      };
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  Future<void> _loadInterviewQuestions() async {
    final questions = await AIService.getInterviewQuestions(
      jobTitle: widget.applicant.jobTitle,
      company: widget.applicant.employerName ?? '',
      skills: _resumeAnalysis?['skills'] ?? [],
    );

    setState(() {
      _interviewQuestions = questions;
    });
  }

  Future<void> _updateStatus(ApplicationStatus status) async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application ${status.display}'),
          backgroundColor: ApplicationStatusColors.getColor(status),
        ),
      );
      Navigator.pop(context, true); // Return to refresh list
    }
  }

  void _showMoreOptions() {
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
                'More Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: Colors.blue),
              title: const Text('Send Email'),
              onTap: () {
                Navigator.pop(context);
                // Send email
              },
            ),
            ListTile(
              leading: const Icon(Icons.message_outlined, color: Colors.green),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                _openChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.purple),
              title: const Text('Schedule Interview'),
              onTap: () {
                Navigator.pop(context);
                _scheduleInterview();
              },
            ),
            ListTile(
              leading: const Icon(Icons.description, color: Colors.orange),
              title: const Text('Generate Offer Letter'),
              onTap: () {
                Navigator.pop(context);
                _generateLetter('offer');
              },
            ),
            if (widget.applicant.status != ApplicationStatus.rejected)
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: const Text('Reject Application'),
                onTap: () {
                  Navigator.pop(context);
                  _showRejectDialog();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _openChat() {
    Navigator.pushNamed(
      context,
      AppRoutes.employerChat,
      arguments: {
        'applicant': widget.applicant,
      },
    );
  }

  void _scheduleInterview() {
    Navigator.pushNamed(
      context,
      AppRoutes.interview,
      arguments: {
        'applicant': widget.applicant,
        'job': {'title': widget.applicant.jobTitle},
      },
    );
  }

  void _generateLetter(String type) {
    Navigator.pushNamed(
      context,
      AppRoutes.generateLetter,
      arguments: {
        'applicant': widget.applicant,
        'letterType': type,
      },
    );
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Application'),
        content: const Text(
            'Are you sure you want to reject this application? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(ApplicationStatus.rejected);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
        ApplicationStatusColors.getColor(widget.applicant.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.applicant.applicantName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile', icon: Icon(Icons.person)),
            Tab(text: 'Resume', icon: Icon(Icons.description)),
            Tab(text: 'Analysis', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Profile Tab
          _buildProfileTab(statusColor),

          // Resume Tab
          _buildResumeTab(),

          // Analysis Tab
          _buildAnalysisTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProfileTab(Color statusColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: statusColor.withOpacity(0.1),
                  child: Text(
                    widget.applicant.applicantName[0].toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.applicant.applicantName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.applicant.jobTitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
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
                              ApplicationStatusColors.getIcon(
                                  widget.applicant.status),
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.applicant.status.display,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contact Information
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
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.email_outlined,
                    widget.applicant.applicantEmail ?? 'Not provided'),
                _buildInfoRow(Icons.phone_outlined, '+1 234 567 890'),
                _buildInfoRow(Icons.location_on_outlined, 'New York, NY'),
                _buildInfoRow(Icons.link, 'linkedin.com/in/johndoe'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Application Details
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
                const Text(
                  'Application Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailRow('Applied for', widget.applicant.jobTitle),
                _buildDetailRow(
                    'Applied on', _formatDate(widget.applicant.appliedAt)),
                if (widget.applicant.matchScore != null)
                  _buildDetailRow('Match Score',
                      '${widget.applicant.matchScore!.round()}%'),
                if (widget.applicant.coverLetter != null) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Cover Letter',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.applicant.coverLetter!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Skills
          if (_resumeAnalysis != null && _resumeAnalysis!['skills'] != null)
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
                  const Text(
                    'Skills',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_resumeAnalysis!['skills'] as List)
                        .map<Widget>((skill) {
                      return SkillChip(
                        label: skill,
                        color: Colors.blue,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResumeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Resume Header
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resume.pdf',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded ${_getTimeAgo(widget.applicant.appliedAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () {
                        // View resume
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () {
                        // Download resume
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Resume Preview
          Container(
            height: 600,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                // Preview Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.visibility, size: 16),
                      SizedBox(width: 8),
                      Text('Resume Preview'),
                    ],
                  ),
                ),

                // Preview Content
                Expanded(
                  child: _resumeAnalysis == null
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Personal Info
                            const Text(
                              'John Doe',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text('Flutter Developer'),
                            const Divider(height: 32),

                            // Summary
                            const Text(
                              'Professional Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Experienced Flutter developer with 3+ years of experience building cross-platform mobile applications. Strong knowledge of Dart, Firebase, and REST APIs.',
                            ),
                            const Divider(height: 32),

                            // Experience
                            const Text(
                              'Work Experience',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...(_resumeAnalysis!['experience'] as List)
                                .map((exp) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exp['role'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(exp['company']),
                                          Text(
                                            exp['duration'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                ,
                            const Divider(height: 32),

                            // Education
                            const Text(
                              'Education',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...(_resumeAnalysis!['education'] as List)
                                .map((edu) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            edu['degree'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(edu['institution']),
                                          Text(
                                            edu['year'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                ,
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    if (_isAnalyzing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI is analyzing resume...'),
          ],
        ),
      );
    }

    if (_resumeAnalysis == null) {
      return const Center(child: Text('No analysis available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overall Score
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue,
                  Colors.purple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'ATS Score',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_resumeAnalysis!['overallScore']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _resumeAnalysis!['overallScore'] / 100,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Score Breakdown
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
              children: [
                _buildScoreBar(
                    'Keywords Match', _resumeAnalysis!['keywordsScore']),
                const SizedBox(height: 12),
                _buildScoreBar(
                    'Formatting', _resumeAnalysis!['formattingScore']),
                const SizedBox(height: 12),
                _buildScoreBar('Length', _resumeAnalysis!['lengthScore']),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Missing Keywords
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
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Missing Keywords',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (_resumeAnalysis!['missingKeywords'] as List)
                      .map<Widget>((keyword) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Text(
                        keyword,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Suggestions
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
                    Icon(Icons.lightbulb, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'Improvement Suggestions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...(_resumeAnalysis!['suggestions'] as List).map((suggestion) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(fontSize: 16),
                        ),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: const TextStyle(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Interview Questions
          if (_interviewQuestions.isNotEmpty)
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
                      Icon(Icons.question_answer, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(
                        'AI Suggested Interview Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._interviewQuestions.map((q) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(
                          q['question'],
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            q['category'],
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Sample Answer:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  q['sampleAnswer'] ??
                                      'No sample answer available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBar(String label, int score) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '$score%',
              style: TextStyle(
                color: score >= 70 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            score >= 70 ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final status = widget.applicant.status;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: _isProcessing
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  if (status == ApplicationStatus.pending) ...[
                    Expanded(
                      child: CustomButton(
                        text: 'Review',
                        onPressed: () =>
                            _updateStatus(ApplicationStatus.reviewed),
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ] else if (status == ApplicationStatus.reviewed) ...[
                    Expanded(
                      child: CustomButton(
                        text: 'Shortlist',
                        onPressed: () =>
                            _updateStatus(ApplicationStatus.shortlisted),
                        backgroundColor: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Reject',
                        onPressed: () => _showRejectDialog(),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ] else if (status == ApplicationStatus.shortlisted) ...[
                    Expanded(
                      child: CustomButton(
                        text: 'Schedule Interview',
                        onPressed: _scheduleInterview,
                        backgroundColor: Colors.purple,
                      ),
                    ),
                  ] else if (status ==
                      ApplicationStatus.interviewScheduled) ...[
                    Expanded(
                      child: CustomButton(
                        text: 'Start Interview',
                        onPressed: () {
                          // Start video interview
                        },
                        backgroundColor: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Generate Offer',
                        onPressed: () => _generateLetter('offer'),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ] else if (status ==
                      ApplicationStatus.interviewCompleted) ...[
                    Expanded(
                      child: CustomButton(
                        text: 'Generate Offer',
                        onPressed: () => _generateLetter('offer'),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ] else if (status == ApplicationStatus.offered) ...[
                    Expanded(
                      child: CustomButton(
                        text: 'Generate Letter',
                        onPressed: () => _generateLetter('joining'),
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chat_outlined),
                      onPressed: _openChat,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
