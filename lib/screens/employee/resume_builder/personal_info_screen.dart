import 'package:flutter/material.dart';
import 'package:jobconnect/widgets/custom_button.dart';
import 'package:jobconnect/utils/validators.dart';

class PersonalInfoStep extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const PersonalInfoStep({
    super.key,
    required this.onSave,
    this.initialData,
  });

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  String? _selectedStatus;

  final List<String> _statusOptions = [
    'Student',
    'Fresh Graduate',
    'Job Seeker',
    'Working Professional',
    'Looking for Change',
    'Freelancer',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _fullNameController.text = widget.initialData!['fullName'] ?? '';
      _emailController.text = widget.initialData!['email'] ?? '';
      _phoneController.text = widget.initialData!['phone'] ?? '';
      _locationController.text = widget.initialData!['location'] ?? '';
      _bioController.text = widget.initialData!['bio'] ?? '';
      _selectedStatus = widget.initialData!['status'];
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      widget.onSave({
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
        'bio': _bioController.text,
        'status': _selectedStatus,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
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
            const SizedBox(height: 8),
            const Text(
              'Tell us about yourself',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name *',
                hintText: 'Enter your full name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: Validators.validateName,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email *',
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField
            (
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: _locationController,
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

            // Current Status
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
              runSpacing: 8,
              children: _statusOptions.map((status) {
                return ChoiceChip(
                  label: Text(status),
                  selected: _selectedStatus == status,
                  onSelected: (selected) {
                    setState(() {
                      _selectedStatus = selected ? status : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Bio
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Professional Summary',
                hintText: 'Write a brief summary about yourself...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              maxLines: 5,
              validator: (value) => Validators.validateDescription(
                value,
                field: 'Summary',
                required: false,
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            CustomButton(
              text: 'Save & Continue',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}