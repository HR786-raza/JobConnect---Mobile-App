import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';
import 'package:jobconnect/models/application_model.dart';
import 'package:jobconnect/utils/helpers.dart';

class InterviewScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const InterviewScreen({super.key, required this.arguments});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _questions = [];
  final List<Map<String, dynamic>> _feedback = [];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedInterviewType = 'Video Call';
  String _selectedDuration = '60 min';
  String notes = '';

  final List<String> _interviewTypes = [
    'Video Call',
    'Phone Call',
    'In-Person',
    'Technical Assessment',
  ];

  final List<String> _durations = [
    '30 min',
    '45 min',
    '60 min',
    '90 min',
    '120 min',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQuestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadQuestions() {
    // Load interview questions based on job
    setState(() {
      _questions.addAll([
        {
          'question': 'Tell me about your experience with Flutter development.',
          'category': 'Technical',
          'difficulty': 'Medium',
          'ideal': 'Look for specific projects and challenges overcome',
        },
        {
          'question': 'How do you handle state management in Flutter?',
          'category': 'Technical',
          'difficulty': 'Medium',
          'ideal': 'Should mention Provider, BLoC, GetX, etc.',
        },
        {
          'question': 'Describe a challenging project you worked on.',
          'category': 'Behavioral',
          'difficulty': 'Medium',
          'ideal': 'Use STAR method: Situation, Task, Action, Result',
        },
        {
          'question': 'How do you stay updated with latest technologies?',
          'category': 'General',
          'difficulty': 'Easy',
          'ideal': 'Look for blogs, courses, side projects',
        },
      ]);
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _scheduleInterview() {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Save interview schedule
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Interview scheduled successfully'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _startInterview() {
    // In a real app, this would launch video call
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Interview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose interview platform:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.video_call, color: Colors.blue),
              title: const Text('Google Meet'),
              onTap: () {
                Navigator.pop(context);
                _launchVideoCall('meet');
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_call, color: Colors.green),
              title: const Text('Zoom'),
              onTap: () {
                Navigator.pop(context);
                _launchVideoCall('zoom');
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.orange),
              title: const Text('Phone Call'),
              onTap: () {
                Navigator.pop(context);
                _startPhoneCall();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _launchVideoCall(String platform) {
    // In a real app, this would launch the video call URL
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting $platform video call...'),
      ),
    );
  }

  void _startPhoneCall() {
    // In a real app, this would initiate a phone call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Initiating phone call...')),
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

  void addFeedback(String question, String feedback, int rating) {
    setState(() {
      _feedback.add({
        'question': question,
        'feedback': feedback,
        'rating': rating,
        'timestamp': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final applicant = widget.arguments['applicant'] as ApplicationModel;
    final job = widget.arguments['job'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text('Interview: ${applicant.applicantName}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Schedule', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Conduct', icon: Icon(Icons.video_call)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Schedule Tab
          _buildScheduleTab(applicant, job),

          // Conduct Tab
          _buildConductTab(applicant),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(
      ApplicationModel applicant, Map<String, dynamic> job) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Applicant Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Text(
                      applicant.applicantName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 20,
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
                          applicant.applicantName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job['title'],
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Applied: ${_getTimeAgo(applicant.appliedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Schedule Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule Interview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date Picker
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      _selectedDate == null
                          ? 'Select Date'
                          : Helpers.formatDate(_selectedDate!),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _selectDate,
                  ),
                  const Divider(),

                  // Time Picker
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(
                      _selectedTime == null
                          ? 'Select Time'
                          : _selectedTime!.format(context),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _selectTime,
                  ),
                  const Divider(),

                  // Interview Type
                  DropdownButtonFormField<String>(
                    initialValue: _selectedInterviewType,
                    decoration: const InputDecoration(
                      labelText: 'Interview Type',
                      prefixIcon: Icon(Icons.video_call),
                      border: InputBorder.none,
                    ),
                    items: _interviewTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedInterviewType = value!;
                      });
                    },
                  ),
                  const Divider(),

                  // Duration
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDuration,
                    decoration: const InputDecoration(
                      labelText: 'Duration',
                      prefixIcon: Icon(Icons.timer),
                      border: InputBorder.none,
                    ),
                    items: _durations.map((duration) {
                      return DropdownMenuItem(
                        value: duration,
                        child: Text(duration),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDuration = value!;
                      });
                    },
                  ),
                  const Divider(),

                  // Notes
                  TextField(
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Additional Notes',
                      hintText: 'Add any special instructions or notes...',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      notes = value;
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Schedule',
                  onPressed: _scheduleInterview,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Start Now',
                  onPressed: _startInterview,
                  isOutlined: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConductTab(ApplicationModel applicant) {
    return Column(
      children: [
        // Interview Controls
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _startInterview,
                  icon: const Icon(Icons.video_call),
                  label: const Text('Start Video Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Questions List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  title: Text(
                    question['question'],
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          question['category'],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          question['difficulty'],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ideal Answer:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question['ideal'],
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Feedback:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Enter feedback...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text('Rating: '),
                              ...List.generate(5, (starIndex) {
                                return IconButton(
                                  icon: Icon(
                                    starIndex < 3
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    // Set rating
                                  },
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Submit Feedback Button
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: CustomButton(
            text: 'Submit Interview Feedback',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback submitted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
