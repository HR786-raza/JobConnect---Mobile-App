import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  int _currentStep = 0;
  final int _totalSteps = 5;

  final List<ResumeStep> _steps = [
    ResumeStep(
      title: 'Personal Info',
      icon: Icons.person,
      isCompleted: false,
    ),
    ResumeStep(
      title: 'Education',
      icon: Icons.school,
      isCompleted: false,
    ),
    ResumeStep(
      title: 'Skills',
      icon: Icons.code,
      isCompleted: false,
    ),
    ResumeStep(
      title: 'Experience',
      icon: Icons.work,
      isCompleted: false,
    ),
    ResumeStep(
      title: 'Projects',
      icon: Icons.folder,
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Your Resume'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step $_currentStep of $_totalSteps',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(_currentStep / _totalSteps * 100).toInt()}% Complete',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _currentStep / _totalSteps,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // Step Indicators
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(_steps.length, (index) {
                return _buildStepIndicator(index);
              }),
            ),
          ),
          const SizedBox(height: 16),
          // Step Content
          Expanded(
            child: _buildStepContent(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
              if (_currentStep > 0)
                Expanded(
                  child: CustomButton(
                    text: 'Previous',
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                    isOutlined: true,
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: _currentStep == _totalSteps - 1 ? 'Generate Resume' : 'Next',
                  onPressed: () {
                    if (_currentStep < _totalSteps - 1) {
                      setState(() {
                        _currentStep++;
                      });
                    } else {
                      _generateResume();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int index) {
    final isActive = index <= _currentStep;
    final isCurrent = index == _currentStep;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCurrent
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _steps[index].icon,
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _steps[index].title,
            style: TextStyle(
              fontSize: 12,
              color: isCurrent
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfo();
      case 1:
        return _buildEducation();
      case 2:
        return _buildSkills();
      case 3:
        return _buildExperience();
      case 4:
        return _buildProjects();
      default:
        return Container();
    }
  }

  Widget _buildPersonalInfo() {
    String? selectedStatus;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Phone',
              hintText: 'Enter your phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Location',
              hintText: 'City, Country',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Current Situation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              'Student',
              'Fresh Graduate',
              'Job Seeker',
              'Working Professional',
            ].map((status) {
              return FilterChip(
                label: Text(status),
                selected: selectedStatus == status,
                onSelected: (selected) {
                  setState(() {
                    selectedStatus = selected ? status : null;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEducation() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Education',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildEducationCard(
          degree: 'Bachelor of Science in Computer Science',
          institution: 'University of Technology',
          year: '2020 - 2024',
          grade: '3.8 GPA',
        ),
        const SizedBox(height: 12),
        _buildEducationCard(
          degree: 'High School Diploma',
          institution: 'City High School',
          year: '2018 - 2020',
          grade: '95%',
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Add Education',
          onPressed: () {},
          isOutlined: true,
        ),
      ],
    );
  }

  Widget _buildEducationCard({
    required String degree,
    required String institution,
    required String year,
    required String grade,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    degree,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              institution,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    year,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    grade,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkills() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skills & Languages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your technical skills and languages',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Technical Skills',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
              'REST APIs',
              'Git',
              'Provider',
              'BLoC',
            ].map((skill) {
              return Chip(
                label: Text(skill),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {},
                backgroundColor: Colors.blue.withOpacity(0.1),
                labelStyle: const TextStyle(color: Colors.blue),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: 'Add a skill',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Languages',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildLanguageItem('English', 'Fluent'),
          _buildLanguageItem('Spanish', 'Intermediate'),
          _buildLanguageItem('French', 'Basic'),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(String language, String proficiency) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  language,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  proficiency,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExperience() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Work Experience',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildExperienceCard(
          position: 'Flutter Developer',
          company: 'Tech Solutions Inc',
          duration: 'Jan 2023 - Present',
          description: 'Developing cross-platform mobile applications using Flutter',
        ),
        const SizedBox(height: 12),
        _buildExperienceCard(
          position: 'Junior Developer',
          company: 'StartUp Labs',
          duration: 'Jun 2022 - Dec 2022',
          description: 'Assisted in building mobile apps and fixing bugs',
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Add Experience',
          onPressed: () {},
          isOutlined: true,
        ),
      ],
    );
  }

  Widget _buildExperienceCard({
    required String position,
    required String company,
    required String duration,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    position,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              company,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                duration,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                height: 1.5,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjects() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Projects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _buildProjectCard(
          title: 'JobConnect',
          description: 'A smart job portal with AI-based job matching',
          technologies: 'Flutter, Firebase, AI',
          link: 'github.com/jobconnect',
        ),
        const SizedBox(height: 12),
        _buildProjectCard(
          title: 'E-Commerce App',
          description: 'Full-featured mobile shopping application',
          technologies: 'Flutter, Stripe, REST API',
          link: 'github.com/ecommerce',
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Add Project',
          onPressed: () {},
          isOutlined: true,
        ),
      ],
    );
  }

  Widget _buildProjectCard({
    required String title,
    required String description,
    required String technologies,
    required String link,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                technologies,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.purple,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.link,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  link,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _generateResume() {
    // Implement resume generation logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
        content: const Text('Your resume has been generated successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ResumeStep {
  final String title;
  final IconData icon;
  bool isCompleted;

  ResumeStep({
    required this.title,
    required this.icon,
    this.isCompleted = false,
  });
}