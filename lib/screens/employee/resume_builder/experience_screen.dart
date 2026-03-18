import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';

class ExperienceStep extends StatefulWidget {
  final Function(List<dynamic>) onSave;
  final List<dynamic>? initialData;

  const ExperienceStep({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<ExperienceStep> createState() => _ExperienceStepState();
}

class _ExperienceStepState extends State<ExperienceStep> {
  List<Map<String, dynamic>> _experienceList = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _experienceList = List<Map<String, dynamic>>.from(widget.initialData!);
    } else {
      _addExperience();
    }
  }

  void _addExperience() {
    setState(() {
      _experienceList.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': '',
        'company': '',
        'location': '',
        'startDate': null,
        'endDate': null,
        'isCurrent': false,
        'description': '',
        'achievements': [],
      });
    });
  }

  void _removeExperience(String id) {
    setState(() {
      _experienceList.removeWhere((exp) => exp['id'] == id);
    });
  }

  void _updateExperience(String id, String field, dynamic value) {
    final index = _experienceList.indexWhere((exp) => exp['id'] == id);
    if (index != -1) {
      setState(() {
        _experienceList[index][field] = value;
      });
    }
  }

  void save() {
    widget.onSave(_experienceList);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Experience saved'),
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
            itemCount: _experienceList.length,
            itemBuilder: (context, index) {
              final experience = _experienceList[index];
              return _buildExperienceCard(experience, index);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Add Another Experience',
                  onPressed: _addExperience,
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

  Widget _buildExperienceCard(Map<String, dynamic> experience, int index) {
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
                  'Experience #${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_experienceList.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeExperience(experience['id']),
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Job Title
            TextFormField(
              initialValue: experience['title'],
              decoration: InputDecoration(
                labelText: 'Job Title *',
                hintText: 'e.g., Senior Flutter Developer',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _updateExperience(experience['id'], 'title', value),
            ),
            const SizedBox(height: 12),

            // Company
            TextFormField(
              initialValue: experience['company'],
              decoration: InputDecoration(
                labelText: 'Company *',
                hintText: 'e.g., Tech Corp',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _updateExperience(experience['id'], 'company', value),
            ),
            const SizedBox(height: 12),

            // Location
            TextFormField(
              initialValue: experience['location'],
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'e.g., New York, NY',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => _updateExperience(experience['id'], 'location', value),
            ),
            const SizedBox(height: 12),

            // Dates
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: experience['startDate'],
                    decoration: InputDecoration(
                      labelText: 'Start Date *',
                      hintText: 'MM/YYYY',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) => _updateExperience(experience['id'], 'startDate', value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: experience['endDate'],
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      hintText: 'MM/YYYY',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    enabled: !experience['isCurrent'],
                    onChanged: (value) => _updateExperience(experience['id'], 'endDate', value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Currently Working
            Row(
              children: [
                Checkbox(
                  value: experience['isCurrent'],
                  onChanged: (value) {
                    _updateExperience(experience['id'], 'isCurrent', value);
                    if (value == true) {
                      _updateExperience(experience['id'], 'endDate', null);
                    }
                  },
                ),
                const Text('I currently work here'),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            TextFormField(
              initialValue: experience['description'],
              decoration: InputDecoration(
                labelText: 'Description *',
                hintText: 'Describe your responsibilities and achievements...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 4,
              onChanged: (value) => _updateExperience(experience['id'], 'description', value),
            ),
          ],
        ),
      ),
    );
  }
}