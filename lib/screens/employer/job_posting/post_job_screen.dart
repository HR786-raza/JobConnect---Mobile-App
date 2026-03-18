import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';
import 'package:jobconnect/models/job_model.dart';
import 'package:jobconnect/providers/job_provider.dart';
import 'package:jobconnect/providers/auth_provider.dart';
import 'package:jobconnect/utils/validators.dart';
import 'package:provider/provider.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _responsibilitiesController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();
  final _vacanciesController = TextEditingController(text: '1');
  
  String _selectedJobType = 'Full Time';
  String _selectedExperience = 'Entry Level';
  bool _isRemote = false;
  final List<String> _selectedSkills = [];
  
  final List<String> _jobTypes = [
    'Full Time',
    'Part Time',
    'Internship',
    'Contract',
    'Freelance',
  ];

  final List<String> _experienceLevels = [
    'Entry Level',
    'Mid Level',
    'Senior Level',
    'Lead',
    'Manager',
  ];

  final List<String> _availableSkills = [
    'Flutter',
    'Dart',
    'Firebase',
    'REST APIs',
    'Git',
    'UI/UX',
    'Python',
    'Java',
    'Swift',
    'Kotlin',
    'React',
    'Node.js',
    'MongoDB',
    'PostgreSQL',
    'AWS',
    'Docker',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _responsibilitiesController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _vacanciesController.dispose();
    super.dispose();
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    // Parse requirements and responsibilities
    final requirements = _requirementsController.text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    
    final responsibilities = _responsibilitiesController.text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    // Parse salary
    double? salaryMin = double.tryParse(_salaryMinController.text);
    double? salaryMax = double.tryParse(_salaryMaxController.text);
    
    if (salaryMin != null) salaryMin *= 1000; // Convert to actual value
    if (salaryMax != null) salaryMax *= 1000;

    // Create job model
    final job = JobModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employerId: authProvider.currentUser!.uid,
      employerName: authProvider.currentUser!.displayName ?? 'Company',
      employerLogo: authProvider.currentUser!.photoURL,
      title: _titleController.text,
      description: _descriptionController.text,
      requirements: requirements,
      responsibilities: responsibilities,
      skills: _selectedSkills,
      jobType: _parseJobType(_selectedJobType),
      experienceLevel: _parseExperienceLevel(_selectedExperience),
      location: _locationController.text,
      isRemote: _isRemote,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      vacancies: int.tryParse(_vacanciesController.text) ?? 1,
      postedDate: DateTime.now(),
      deadline: DateTime.now().add(const Duration(days: 30)),
      status: JobStatus.active,
    );

    final success = await jobProvider.postJob(job);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  JobType _parseJobType(String type) {
    switch (type) {
      case 'Full Time':
        return JobType.fullTime;
      case 'Part Time':
        return JobType.partTime;
      case 'Internship':
        return JobType.internship;
      case 'Contract':
        return JobType.contract;
      case 'Freelance':
        return JobType.freelance;
      default:
        return JobType.fullTime;
    }
  }

  ExperienceLevel _parseExperienceLevel(String level) {
    switch (level) {
      case 'Entry Level':
        return ExperienceLevel.entry;
      case 'Mid Level':
        return ExperienceLevel.mid;
      case 'Senior Level':
        return ExperienceLevel.senior;
      case 'Lead':
        return ExperienceLevel.lead;
      case 'Manager':
        return ExperienceLevel.manager;
      default:
        return ExperienceLevel.entry;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post New Job'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Job Title *',
                  hintText: 'e.g., Senior Flutter Developer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.work_outline),
                ),
                validator: Validators.validateJobTitle,
              ),
              const SizedBox(height: 16),

              // Location and Remote
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location *',
                        hintText: 'e.g., New York, NY',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      validator: Validators.validateLocation,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _isRemote,
                          onChanged: (value) {
                            setState(() {
                              _isRemote = value ?? false;
                            });
                          },
                        ),
                        const Text('Remote'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Job Type and Experience
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedJobType,
                      decoration: InputDecoration(
                        labelText: 'Job Type *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.work_outline),
                      ),
                      items: _jobTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedJobType = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedExperience,
                      decoration: InputDecoration(
                        labelText: 'Experience Level *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.trending_up),
                      ),
                      items: _experienceLevels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedExperience = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Salary Range
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salaryMinController,
                      decoration: InputDecoration(
                        labelText: 'Min Salary (k)',
                        hintText: 'e.g., 50',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateNumber(
                        value,
                        field: 'Minimum salary',
                        required: false,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _salaryMaxController,
                      decoration: InputDecoration(
                        labelText: 'Max Salary (k)',
                        hintText: 'e.g., 80',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) => Validators.validateNumber(
                        value,
                        field: 'Maximum salary',
                        required: false,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Vacancies
              TextFormField(
                controller: _vacanciesController,
                decoration: InputDecoration(
                  labelText: 'Number of Vacancies',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.people_outline),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // Description
              const Text(
                'Job Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe the role and responsibilities...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                maxLines: 5,
                validator: (value) => Validators.validateDescription(
                  value,
                  field: 'Job description',
                  minLength: 20,
                ),
              ),
              const SizedBox(height: 16),

              // Requirements
              const Text(
                'Requirements (one per line)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _requirementsController,
                decoration: InputDecoration(
                  hintText: '• Bachelor\'s degree in Computer Science\n• 3+ years of experience\n• Strong communication skills',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.list_alt),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 16),

              // Responsibilities
              const Text(
                'Responsibilities (one per line)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _responsibilitiesController,
                decoration: InputDecoration(
                  hintText: '• Develop and maintain mobile applications\n• Collaborate with cross-functional teams\n• Write clean and maintainable code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.task_alt),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              // Skills
              const Text(
                'Required Skills',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSkills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  return FilterChip(
                    label: Text(skill),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSkills.add(skill);
                        } else {
                          _selectedSkills.remove(skill);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              if (_selectedSkills.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Selected: ${_selectedSkills.length} skills',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],

              const SizedBox(height: 32),

              // Submit Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Save as Draft',
                      onPressed: () {
                        // Save as draft
                      },
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Post Job',
                      onPressed: _saveJob,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}