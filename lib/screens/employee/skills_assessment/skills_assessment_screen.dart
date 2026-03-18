import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';

class SkillsAssessmentScreen extends StatefulWidget {
  const SkillsAssessmentScreen({super.key});

  @override
  State<SkillsAssessmentScreen> createState() => _SkillsAssessmentScreenState();
}

class _SkillsAssessmentScreenState extends State<SkillsAssessmentScreen> {
  int _currentQuestionIndex = 0;
  bool _assessmentStarted = false;
  Map<String, dynamic> results = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'skill': 'Flutter',
      'question': 'What is the main programming language used in Flutter?',
      'options': ['Java', 'Kotlin', 'Dart', 'Swift'],
      'correct': 2,
    },
    {
      'skill': 'Flutter',
      'question': 'Which widget is used for creating a scrollable list?',
      'options': ['Column', 'ListView', 'GridView', 'Stack'],
      'correct': 1,
    },
    {
      'skill': 'Flutter',
      'question': 'What is the command to create a new Flutter project?',
      'options': [
        'flutter create project',
        'flutter new project',
        'flutter init project',
        'flutter start project'
      ],
      'correct': 0,
    },
    {
      'skill': 'Dart',
      'question': 'What is the correct way to declare a nullable variable in Dart?',
      'options': [
        'String name;',
        'String? name;',
        'Nullable<String> name;',
        'String name = null;'
      ],
      'correct': 1,
    },
    {
      'skill': 'Firebase',
      'question': 'Which Firebase service is used for user authentication?',
      'options': [
        'Firebase Auth',
        'Firebase Core',
        'Firebase Database',
        'Firebase Storage'
      ],
      'correct': 0,
    },
  ];

  List<int?> _selectedAnswers = [];

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(_questions.length, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skills Assessment'),
      ),
      body: _assessmentStarted ? _buildAssessment() : _buildStartScreen(),
    );
  }

  Widget _buildStartScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.assessment,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI-Powered Skills Assessment',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Take our AI-based assessment to determine your skill level and get personalized job recommendations',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'How it works:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStep(
            icon: Icons.question_answer,
            title: 'Answer Questions',
            description: 'Answer a series of questions based on your selected skills',
          ),
          _buildStep(
            icon: Icons.auto_awesome,
            title: 'AI Analysis',
            description: 'Our AI analyzes your responses in real-time',
          ),
          _buildStep(
            icon: Icons.star,
            title: 'Get Your Level',
            description: 'Receive detailed feedback and your skill level',
          ),
          _buildStep(
            icon: Icons.work,
            title: 'Job Matches',
            description: 'Get matched with jobs that fit your skill level',
          ),
          const SizedBox(height: 24),
          const Text(
            'Skills to be assessed:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Flutter',
              'Dart',
              'Firebase',
              'UI/UX',
              'State Management',
              'REST APIs',
            ].map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Start Assessment',
            onPressed: () {
              setState(() {
                _assessmentStarted = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        ],
      ),
    );
  }

  Widget _buildAssessment() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions.length,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Skill: ${_questions[_currentQuestionIndex]['skill']}',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _questions[_currentQuestionIndex]['question'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(
                  _questions[_currentQuestionIndex]['options'].length,
                  (index) {
                    return _buildOption(
                      index,
                      _questions[_currentQuestionIndex]['options'][index],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Container(
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
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: CustomButton(
                      text: 'Previous',
                      onPressed: () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      isOutlined: true,
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: _currentQuestionIndex == _questions.length - 1 ? 'Submit' : 'Next',
                    onPressed: () {
                      if (_selectedAnswers[_currentQuestionIndex] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select an answer')),
                        );
                        return;
                      }

                      if (_currentQuestionIndex < _questions.length - 1) {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      } else {
                        _showResults();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOption(int index, String text) {
    bool isSelected = _selectedAnswers[_currentQuestionIndex] == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnswers[_currentQuestionIndex] = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResults() {
    int correctAnswers = 0;
    for (int i = 0; i < _questions.length; i++) {
      if (_selectedAnswers[i] == _questions[i]['correct']) {
        correctAnswers++;
      }
    }

    double percentage = (correctAnswers / _questions.length) * 100;
    String level;
    Color levelColor;

    if (percentage >= 80) {
      level = 'Expert';
      levelColor = Colors.purple;
    } else if (percentage >= 60) {
      level = 'Advanced';
      levelColor = Colors.blue;
    } else if (percentage >= 40) {
      level = 'Intermediate';
      levelColor = Colors.green;
    } else if (percentage >= 20) {
      level = 'Beginner';
      levelColor = Colors.orange;
    } else {
      level = 'Novice';
      levelColor = Colors.red;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Icon(Icons.assessment, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Assessment Complete!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: levelColor.withOpacity(0.1),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${percentage.round()}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                    Text(
                      level,
                      style: TextStyle(
                        fontSize: 18,
                        color: levelColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You answered $correctAnswers out of ${_questions.length} questions correctly.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Skill Level: $level',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: levelColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Go back to assessment start
            },
            child: const Text('Done'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _assessmentStarted = false;
                _currentQuestionIndex = 0;
                _selectedAnswers = List.filled(_questions.length, null);
              });
            },
            child: const Text('Retake'),
          ),
        ],
      ),
    );
  }
}