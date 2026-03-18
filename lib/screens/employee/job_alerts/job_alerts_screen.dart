import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';

class JobAlertsScreen extends StatefulWidget {
  const JobAlertsScreen({super.key});

  @override
  State<JobAlertsScreen> createState() => _JobAlertsScreenState();
}

class _JobAlertsScreenState extends State<JobAlertsScreen> {
  bool _notificationsEnabled = true;
  List<Map<String, dynamic>> _alerts = [];
  
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _salaryMinController = TextEditingController();
  final TextEditingController _salaryMaxController = TextEditingController();
  
  String _selectedJobType = 'All';
  bool _showAddAlert = false;

  final List<String> jobTypes = [
    'All',
    'Full Time',
    'Part Time',
    'Internship',
    'Contract',
    'Remote'
  ];

  @override
  void initState() {
    super.initState();
    _loadSampleAlerts();
  }

  void _loadSampleAlerts() {
    _alerts = [
      {
        'id': '1',
        'title': 'Flutter Developer Jobs',
        'city': 'New York',
        'jobType': 'Full Time',
        'salaryRange': '\$80k - \$120k',
        'frequency': 'Daily',
        'enabled': true,
      },
      {
        'id': '2',
        'title': 'Mobile Developer Internships',
        'city': 'San Francisco',
        'jobType': 'Internship',
        'salaryRange': '\$50k - \$70k',
        'frequency': 'Weekly',
        'enabled': true,
      },
      {
        'id': '3',
        'title': 'Remote UI/UX Jobs',
        'city': 'Remote',
        'jobType': 'All',
        'salaryRange': 'Any',
        'frequency': 'Daily',
        'enabled': false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Alerts'),
        actions: [
          IconButton(
            icon: Icon(_showAddAlert ? Icons.close : Icons.add),
            onPressed: () {
              setState(() {
                _showAddAlert = !_showAddAlert;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_showAddAlert) _buildAddAlertForm(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                return _buildAlertCard(_alerts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAlertForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create New Alert',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cityController,
            decoration: InputDecoration(
              labelText: 'City',
              hintText: 'e.g., New York, San Francisco',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedJobType,
            decoration: InputDecoration(
              labelText: 'Job Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.work_outline),
            ),
            items: jobTypes.map((type) {
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _salaryMinController,
                  decoration: InputDecoration(
                    labelText: 'Min Salary',
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _salaryMaxController,
                  decoration: InputDecoration(
                    labelText: 'Max Salary',
                    hintText: '200k',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  onPressed: () {
                    setState(() {
                      _showAddAlert = false;
                      _cityController.clear();
                      _salaryMinController.clear();
                      _salaryMaxController.clear();
                      _selectedJobType = 'All';
                    });
                  },
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomButton(
                  text: 'Create Alert',
                  onPressed: () {
                    // Save alert
                    setState(() {
                      _showAddAlert = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job alert created successfully')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    alert['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: alert['enabled'],
                  onChanged: (value) {
                    setState(() {
                      alert['enabled'] = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildAlertChip(
                  Icons.location_on,
                  alert['city'],
                ),
                _buildAlertChip(
                  Icons.work_outline,
                  alert['jobType'],
                ),
                _buildAlertChip(
                  Icons.attach_money,
                  alert['salaryRange'],
                ),
                _buildAlertChip(
                  Icons.notifications,
                  alert['frequency'],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    // Edit alert
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _alerts.remove(alert);
                    });
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    super.dispose();
  }
}