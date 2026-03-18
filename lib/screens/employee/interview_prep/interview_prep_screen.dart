import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';

class InterviewPrepScreen extends StatefulWidget {
  const InterviewPrepScreen({super.key});

  @override
  State<InterviewPrepScreen> createState() => _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends State<InterviewPrepScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSkill = 'Flutter';
  String _selectedCompany = 'Any Company';
  bool _isRecording = false;

  final List<String> skills = [
    'Flutter',
    'Dart',
    'Firebase',
    'UI/UX',
    'System Design',
    'Behavioral',
  ];

  final List<String> companies = [
    'Any Company',
    'Google',
    'Microsoft',
    'Amazon',
    'Apple',
    'Facebook',
    'Startups',
  ];

  final List<Map<String, dynamic>> questions = [
    {
      'skill': 'Flutter',
      'question': 'What is the difference between StatelessWidget and StatefulWidget?',
      'difficulty': 'Beginner',
      'company': 'Any',
    },
    {
      'skill': 'Flutter',
      'question': 'Explain the widget tree and element tree in Flutter.',
      'difficulty': 'Intermediate',
      'company': 'Google',
    },
    {
      'skill': 'Dart',
      'question': 'What are null safety features in Dart?',
      'difficulty': 'Intermediate',
      'company': 'Microsoft',
    },
    {
      'skill': 'Firebase',
      'question': 'How does Firebase Realtime Database differ from Cloud Firestore?',
      'difficulty': 'Advanced',
      'company': 'Amazon',
    },
    {
      'skill': 'Behavioral',
      'question': 'Tell me about a time you faced a difficult challenge and how you overcame it.',
      'difficulty': 'Beginner',
      'company': 'Any',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Interview Preparation'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Practice', icon: Icon(Icons.mic)),
            Tab(text: 'Questions', icon: Icon(Icons.question_answer)),
            Tab(text: 'Tips', icon: Icon(Icons.lightbulb)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPracticeTab(),
          _buildQuestionsTab(),
          _buildTipsTab(),
        ],
      ),
    );
  }

  Widget _buildPracticeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  'AI Mock Interview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Practice with our AI interviewer',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Start New Interview',
                  onPressed: () {
                    _startMockInterview();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Skills',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) {
              return FilterChip(
                label: Text(skill),
                selected: _selectedSkill == skill,
                onSelected: (selected) {
                  setState(() {
                    _selectedSkill = skill;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Target Company',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedCompany,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: companies.map((company) {
              return DropdownMenuItem(
                value: company,
                child: Text(company),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCompany = value!;
              });
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent Practice Sessions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSessionCard(
            'Flutter Basics',
            '85% Score',
            '2 days ago',
            Icons.code,
          ),
          _buildSessionCard(
            'Behavioral Questions',
            '92% Score',
            '5 days ago',
            Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(String title, String score, String date, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            score,
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: questions.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getDifficultyColor(questions[index]['difficulty']).withOpacity(0.1),
              child: Icon(
                Icons.question_answer,
                color: _getDifficultyColor(questions[index]['difficulty']),
                size: 18,
              ),
            ),
            title: Text(
              questions[index]['question'],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(questions[index]['difficulty']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    questions[index]['difficulty'],
                    style: TextStyle(
                      fontSize: 10,
                      color: _getDifficultyColor(questions[index]['difficulty']),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (questions[index]['company'] != 'Any')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      questions[index]['company'],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
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
                      'Sample Answer:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getSampleAnswer(questions[index]['question']),
                      style: TextStyle(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _startPractice(questions[index]['question']);
                            },
                            icon: const Icon(Icons.mic),
                            label: const Text('Practice'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Save question
                            },
                            icon: const Icon(Icons.bookmark_border),
                            label: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Interview Tips',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTipCard(
            'Research the Company',
            'Learn about the company\'s products, culture, and recent news',
            Icons.business,
          ),
          _buildTipCard(
            'Practice Common Questions',
            'Prepare answers for common interview questions',
            Icons.question_answer,
          ),
          _buildTipCard(
            'Use STAR Method',
            'Situation, Task, Action, Result - structure your answers',
            Icons.star,
          ),
          _buildTipCard(
            'Prepare Questions',
            'Have thoughtful questions ready for the interviewer',
            Icons.help,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 40),
                const SizedBox(height: 8),
                const Text(
                  'AI Tip of the Day',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Based on your profile, focus on practicing Flutter state management questions. This is a common topic in technical interviews.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String description, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getSampleAnswer(String question) {
    // This would be AI-generated in real implementation
    return 'This is a sample answer for the question. In a real implementation, this would be generated by AI based on the question and best practices.';
  }

  void _startMockInterview() {
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
                  'AI Mock Interview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Question 1 of 5',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'What is the difference between StatelessWidget and StatefulWidget in Flutter?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _isRecording ? Icons.mic : Icons.mic_none,
                                  color: _isRecording ? Colors.red : Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isRecording ? 'Recording...' : 'Tap to start answering',
                                    style: TextStyle(
                                      color: _isRecording ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _isRecording,
                                  onChanged: (value) {
                                    setState(() {
                                      _isRecording = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (_isRecording)
                              const LinearProgressIndicator(
                                backgroundColor: Colors.red,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Tips:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Be specific with examples\n• Explain your thought process\n• Mention real projects you\'ve worked on',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Submit Answer',
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Answer submitted for AI analysis')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _startPractice(String question) {
    _startMockInterview();
  }
}