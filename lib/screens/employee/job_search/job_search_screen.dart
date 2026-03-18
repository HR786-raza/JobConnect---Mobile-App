import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/job_card.dart';
import 'package:jobconnect/widgets/custom_button.dart';

class JobSearchScreen extends StatefulWidget {
  const JobSearchScreen({super.key});

  @override
  State<JobSearchScreen> createState() => _JobSearchScreenState();
}

class _JobSearchScreenState extends State<JobSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  RangeValues _salaryRange = const RangeValues(30000, 150000);
  String _selectedCity = 'All Cities';
  String _selectedJobType = 'All Types';
  bool _showFilters = false;

  final List<String> cities = [
    'All Cities',
    'New York',
    'San Francisco',
    'Los Angeles',
    'Chicago',
    'Austin',
    'Seattle',
    'Remote'
  ];

  final List<String> jobTypes = [
    'All Types',
    'Full Time',
    'Part Time',
    'Internship',
    'Contract',
    'Remote'
  ];

  final List<Map<String, dynamic>> searchResults = [
    {
      'title': 'Flutter Developer',
      'company': 'Tech Corp',
      'location': 'New York, NY',
      'salary': '\$120k - \$150k',
      'type': 'Full Time',
      'logo': Icons.code,
    },
    {
      'title': 'Senior Mobile Developer',
      'company': 'Google',
      'location': 'Mountain View, CA',
      'salary': '\$150k - \$200k',
      'type': 'Full Time',
      'logo': Icons.phone_android,
    },
    {
      'title': 'UI/UX Designer',
      'company': 'Design Studio',
      'location': 'San Francisco, CA',
      'salary': '\$90k - \$120k',
      'type': 'Full Time',
      'logo': Icons.design_services,
    },
    {
      'title': 'Product Manager',
      'company': 'Startup Inc',
      'location': 'Remote',
      'salary': '\$130k - \$160k',
      'type': 'Full Time',
      'logo': Icons.business_center,
    },
    {
      'title': 'Backend Developer',
      'company': 'Amazon',
      'location': 'Seattle, WA',
      'salary': '\$140k - \$180k',
      'type': 'Full Time',
      'logo': Icons.cloud,
    },
    {
      'title': 'iOS Developer Intern',
      'company': 'Apple',
      'location': 'Cupertino, CA',
      'salary': '\$60k - \$70k',
      'type': 'Internship',
      'logo': Icons.apple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Jobs'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list : Icons.filter_list_outlined),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search jobs, companies...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onSubmitted: (_) {
                  // Perform search
                },
              ),
            ),
          ),
          if (_showFilters) _buildFilters(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: JobCard(
                    job: searchResults[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedCity = 'All Cities';
                    _selectedJobType = 'All Types';
                    _salaryRange = const RangeValues(30000, 150000);
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'City',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: cities.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cities[index]),
                    selected: _selectedCity == cities[index],
                    onSelected: (selected) {
                      setState(() {
                        _selectedCity = cities[index];
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Job Type',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: jobTypes.map((type) {
              return ChoiceChip(
                label: Text(type),
                selected: _selectedJobType == type,
                onSelected: (selected) {
                  setState(() {
                    _selectedJobType = type;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Salary Range',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _salaryRange,
            min: 0,
            max: 200000,
            divisions: 20,
            labels: RangeLabels(
              '\$${_salaryRange.start.round()}k',
              '\$${_salaryRange.end.round()}k',
            ),
            onChanged: (values) {
              setState(() {
                _salaryRange = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: \$${_salaryRange.start.round()}k',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Max: \$${_salaryRange.end.round()}k',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Apply Filters',
            onPressed: () {
              setState(() {
                _showFilters = false;
              });
              // Apply filters and refresh results
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}