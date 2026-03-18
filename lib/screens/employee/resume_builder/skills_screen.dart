import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';

class SkillsStep extends StatefulWidget {
  final Function(List<dynamic>) onSave;
  final List<dynamic>? initialData;

  const SkillsStep({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends State<SkillsStep> {
  List<String> _skills = [];
  final List<Map<String, dynamic>> _languages = [];
  final TextEditingController _skillController = TextEditingController();

  final List<String> _suggestedSkills = [
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
    'Machine Learning',
    'Data Science',
    'Agile',
    'Scrum',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _skills = List<String>.from(widget.initialData!);
    }
    _addLanguage();
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    if (_skillController.text.isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  void _addLanguage() {
    setState(() {
      _languages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': '',
        'proficiency': 'Conversational',
      });
    });
  }

  void _removeLanguage(String id) {
    setState(() {
      _languages.removeWhere((lang) => lang['id'] == id);
    });
  }

  void _updateLanguage(String id, String field, String value) {
    final index = _languages.indexWhere((lang) => lang['id'] == id);
    if (index != -1) {
      setState(() {
        _languages[index][field] = value;
      });
    }
  }

  void _save() {
    widget.onSave(_skills);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Skills saved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Technical Skills
          const Text(
            'Technical Skills',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your technical skills and rate your proficiency',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // Selected Skills
          if (_skills.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        skill,
                        style: const TextStyle(color: Colors.blue),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeSkill(skill),
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),

          // Add Skill Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillController,
                  decoration: InputDecoration(
                    hintText: 'Enter a skill',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: (_) => _addSkill(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: _addSkill,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Suggested Skills
          const Text(
            'Suggested Skills',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedSkills.map((skill) {
              final isSelected = _skills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _skills.add(skill);
                    } else {
                      _skills.remove(skill);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Languages
          const Text(
            'Languages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Language List
          ..._languages.asMap().entries.map((entry) {
            final index = entry.key;
            final language = entry.value;
            return _buildLanguageCard(language, index);
          }),

          const SizedBox(height: 12),

          // Add Language Button
          CustomButton(
            text: 'Add Language',
            onPressed: _addLanguage,
            isOutlined: true,
            icon: Icons.add,
          ),

          const SizedBox(height: 24),

          // Save Button
          CustomButton(
            text: 'Save & Continue',
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(Map<String, dynamic> language, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: language['name'],
                    decoration: InputDecoration(
                      labelText: 'Language',
                      hintText: 'e.g., English',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) => _updateLanguage(language['id'], 'name', value),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: language['proficiency'],
                decoration: InputDecoration(
                  labelText: 'Proficiency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'Basic', child: Text('Basic')),
                  DropdownMenuItem(value: 'Conversational', child: Text('Conversational')),
                  DropdownMenuItem(value: 'Professional', child: Text('Professional')),
                  DropdownMenuItem(value: 'Native', child: Text('Native')),
                ],
                onChanged: (value) => _updateLanguage(language['id'], 'proficiency', value!),
              ),
            ),
            if (_languages.length > 1)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeLanguage(language['id']),
              ),
          ],
        ),
      ),
    );
  }
}