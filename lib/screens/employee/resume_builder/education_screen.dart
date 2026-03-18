import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';

class EducationStep extends StatefulWidget {
  final Function(List<dynamic>) onSave;
  final List<dynamic>? initialData;

  const EducationStep({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends State<EducationStep> {
  List<Map<String, dynamic>> _educationList = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _educationList = List<Map<String, dynamic>>.from(widget.initialData!);
    } else {
      _addEducation();
    }
  }

  void _addEducation() {
    setState(() {
      _educationList.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'degree': '',
        'institution': '',
        'fieldOfStudy': '',
        'startDate': null,
        'endDate': null,
        'isCurrent': false,
        'grade': '',
        'description': '',
      });
    });
  }

  void _removeEducation(String id) {
    setState(() {
      _educationList.removeWhere((edu) => edu['id'] == id);
    });
  }

  void _updateEducation(String id, String field, dynamic value) {
    final index = _educationList.indexWhere((edu) => edu['id'] == id);
    if (index != -1) {
      setState(() {
        _educationList[index][field] = value;
      });
    }
  }

  void save() {
    widget.onSave(_educationList);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Education saved'),
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
            itemCount: _educationList.length,
            itemBuilder: (context, index) {
              final education = _educationList[index];
              return _buildEducationCard(education, index);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Add Another Education',
                  onPressed: _addEducation,
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

  Widget _buildEducationCard(Map<String, dynamic> education, int index) {
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
                  'Education #${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_educationList.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeEducation(education['id']),
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Degree
            TextFormField(
              initialValue: education['degree'],
              decoration: InputDecoration(
                labelText: 'Degree *',
                hintText: 'e.g., Bachelor of Science in Computer Science',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _updateEducation(education['id'], 'degree', value),
            ),
            const SizedBox(height: 12),

            // Institution
            TextFormField(
              initialValue: education['institution'],
              decoration: InputDecoration(
                labelText: 'Institution *',
                hintText: 'e.g., University of Technology',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _updateEducation(education['id'], 'institution', value),
            ),
            const SizedBox(height: 12),

            // Field of Study
            TextFormField(
              initialValue: education['fieldOfStudy'],
              decoration: InputDecoration(
                labelText: 'Field of Study',
                hintText: 'e.g., Computer Science',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _updateEducation(education['id'], 'fieldOfStudy', value),
            ),
            const SizedBox(height: 12),

            // Dates
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: education['startDate'],
                    decoration: InputDecoration(
                      labelText: 'Start Date *',
                      hintText: 'MM/YYYY',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => _updateEducation(education['id'], 'startDate', value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: education['endDate'],
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      hintText: 'MM/YYYY',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    enabled: !education['isCurrent'],
                    onChanged: (value) => _updateEducation(education['id'], 'endDate', value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Currently Studying
            Row(
              children: [
                Checkbox(
                  value: education['isCurrent'],
                  onChanged: (value) {
                    _updateEducation(education['id'], 'isCurrent', value);
                    if (value == true) {
                      _updateEducation(education['id'], 'endDate', null);
                    }
                  },
                ),
                const Text('I am currently studying here'),
              ],
            ),
            const SizedBox(height: 12),

            // Grade
            TextFormField(
              initialValue: education['grade'],
              decoration: InputDecoration(
                labelText: 'Grade/GPA',
                hintText: 'e.g., 3.8 GPA',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _updateEducation(education['id'], 'grade', value),
            ),
            const SizedBox(height: 12),

            // Description
            TextFormField(
              initialValue: education['description'],
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Add any relevant details...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
              onChanged: (value) => _updateEducation(education['id'], 'description', value),
            ),
          ],
        ),
      ),
    );
  }
}