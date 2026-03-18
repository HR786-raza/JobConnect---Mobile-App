import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';

class ProjectsStep extends StatefulWidget {
  final Function(List<dynamic>) onSave;
  final List<dynamic>? initialData;

  const ProjectsStep({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<ProjectsStep> createState() => _ProjectsStepState();
}

class _ProjectsStepState extends State<ProjectsStep> {
  List<Map<String, dynamic>> _projectsList = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _projectsList = List<Map<String, dynamic>>.from(widget.initialData!);
    } else {
      _addProject();
    }
  }

  void _addProject() {
    setState(() {
      _projectsList.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': '',
        'description': '',
        'technologies': [],
        'projectUrl': '',
        'githubUrl': '',
        'startDate': null,
        'endDate': null,
      });
    });
  }

  void _removeProject(String id) {
    setState(() {
      _projectsList.removeWhere((proj) => proj['id'] == id);
    });
  }

  void _updateProject(String id, String field, dynamic value) {
    final index = _projectsList.indexWhere((proj) => proj['id'] == id);
    if (index != -1) {
      setState(() {
        _projectsList[index][field] = value;
      });
    }
  }

  void save() {
    widget.onSave(_projectsList);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Projects saved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _projectsList.length,
            itemBuilder: (context, index) {
              final project = _projectsList[index];
              return _buildProjectCard(project, index);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Add Another Project',
                  onPressed: _addProject,
                  isOutlined: true,
                  icon: Icons.add,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Project #${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_projectsList.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeProject(project['id']),
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Project Name
            TextFormField(
              initialValue: project['name'],
              decoration: InputDecoration(
                labelText: 'Project Name *',
                hintText: 'e.g., JobConnect Mobile App',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _updateProject(project['id'], 'name', value),
            ),
            const SizedBox(height: 12),

            // Description
            TextFormField(
              initialValue: project['description'],
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe the project, your role, and key features...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
              onChanged: (value) => _updateProject(project['id'], 'description', value),
            ),
            const SizedBox(height: 12),

            // Technologies Used
            const Text(
              'Technologies Used',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Flutter',
                'Dart',
                'Firebase',
                'REST APIs',
                'Git',
              ].map((tech) {
                final isSelected = (project['technologies'] as List?)?.contains(tech) ?? false;
                return FilterChip(
                  label: Text(tech),
                  selected: isSelected,
                  onSelected: (selected) {
                    List<String> currentTechs = List.from(project['technologies'] ?? []);
                    if (selected) {
                      currentTechs.add(tech);
                    } else {
                      currentTechs.remove(tech);
                    }
                    _updateProject(project['id'], 'technologies', currentTechs);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Project URL
            TextFormField(
              initialValue: project['projectUrl'],
              decoration: InputDecoration(
                labelText: 'Project URL',
                hintText: 'https://yourproject.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.link),
              ),
              onChanged: (value) => _updateProject(project['id'], 'projectUrl', value),
            ),
            const SizedBox(height: 12),

            // GitHub URL
            TextFormField(
              initialValue: project['githubUrl'],
              decoration: InputDecoration(
                labelText: 'GitHub URL',
                hintText: 'https://github.com/username/project',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.code),
              ),
              onChanged: (value) => _updateProject(project['id'], 'githubUrl', value),
            ),
          ],
        ),
      ),
    );
  }
}