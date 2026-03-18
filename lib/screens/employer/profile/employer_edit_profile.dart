import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:jobconnect/widgets/custom_button.dart';
import 'package:jobconnect/providers/auth_provider.dart';
import 'package:jobconnect/utils/validators.dart';
import 'package:provider/provider.dart';

class EmployerEditProfile extends StatefulWidget {
  const EmployerEditProfile({super.key});

  @override
  State<EmployerEditProfile> createState() => _EmployerEditProfileState();
}

class _EmployerEditProfileState extends State<EmployerEditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _industryController = TextEditingController();
  final _sizeController = TextEditingController();
  final _foundedController = TextEditingController();
  final _headquartersController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  
  File? _logoImage;
  bool _isLoading = false;
  List<String> _selectedCulture = [];
  List<String> _selectedBenefits = [];

  final List<String> _cultureOptions = [
    'Innovation',
    'Collaboration',
    'Work-Life Balance',
    'Learning',
    'Diversity',
    'Growth',
    'Transparency',
    'Fun',
  ];

  final List<String> _benefitOptions = [
    'Health Insurance',
    'Dental Insurance',
    'Vision Insurance',
    '401(k) Matching',
    'Flexible Hours',
    'Remote Work',
    'Professional Development',
    'Gym Membership',
    'Free Lunch',
    'Paid Time Off',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    _sizeController.dispose();
    _foundedController.dispose();
    _headquartersController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _companyNameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      
      // Load additional company data from user model
      if (user.companyDetails != null) {
        _phoneController.text = user.companyDetails!['phone'] ?? '';
        _websiteController.text = user.companyDetails!['website'] ?? '';
        _industryController.text = user.companyDetails!['industry'] ?? '';
        _sizeController.text = user.companyDetails!['size'] ?? '';
        _foundedController.text = user.companyDetails!['founded'] ?? '';
        _headquartersController.text = user.companyDetails!['headquarters'] ?? '';
        _descriptionController.text = user.companyDetails!['description'] ?? '';
        _addressController.text = user.companyDetails!['address'] ?? '';
        
        if (user.companyDetails!['culture'] != null) {
          _selectedCulture = List<String>.from(user.companyDetails!['culture']);
        }
        if (user.companyDetails!['benefits'] != null) {
          _selectedBenefits = List<String>.from(user.companyDetails!['benefits']);
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _logoImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Upload logo if changed
    String? photoUrl;
    if (_logoImage != null) {
      photoUrl = await authProvider.updateProfileImage(_logoImage!);
    }

    // Update company details
    final companyDetails = {
      'phone': _phoneController.text,
      'website': _websiteController.text,
      'industry': _industryController.text,
      'size': _sizeController.text,
      'founded': _foundedController.text,
      'headquarters': _headquartersController.text,
      'description': _descriptionController.text,
      'address': _addressController.text,
      'culture': _selectedCulture,
      'benefits': _selectedBenefits,
    };

    await authProvider.updateUserData({
      'displayName': _companyNameController.text,
      if (photoUrl != null) 'photoURL': photoUrl,
      'companyDetails': companyDetails,
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Company Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Logo Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                        image: _logoImage != null
                            ? DecorationImage(
                                image: FileImage(_logoImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _logoImage == null
                          ? CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                              child: Text(
                                _companyNameController.text.isNotEmpty
                                    ? _companyNameController.text[0].toUpperCase()
                                    : 'C',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Company Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Company Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      // Company Name
                      TextFormField(
                        controller: _companyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: Validators.validateCompanyName,
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: Validators.validateEmail,
                        enabled: false, // Email cannot be changed
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: Validators.validatePhone,
                      ),
                      const SizedBox(height: 16),

                      // Website
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(
                          labelText: 'Website',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        validator: Validators.validateUrl,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Company Details
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Company Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      // Industry
                      TextFormField(
                        controller: _industryController,
                        decoration: const InputDecoration(
                          labelText: 'Industry',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Company Size
                      DropdownButtonFormField<String>(
                        initialValue: _sizeController.text.isEmpty ? null : _sizeController.text,
                        decoration: const InputDecoration(
                          labelText: 'Company Size',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
                        items: [
                          '1-10 employees',
                          '11-50 employees',
                          '51-200 employees',
                          '201-500 employees',
                          '501-1000 employees',
                          '1000+ employees',
                        ].map((size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text(size),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _sizeController.text = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Founded Year
                      TextFormField(
                        controller: _foundedController,
                        decoration: const InputDecoration(
                          labelText: 'Founded Year',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      // Headquarters
                      TextFormField(
                        controller: _headquartersController,
                        decoration: const InputDecoration(
                          labelText: 'Headquarters',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Full Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.map),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Company Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About Company',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Tell us about your company...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        validator: (value) => Validators.validateDescription(
                          value,
                          field: 'Description',
                          required: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Company Culture
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Company Culture',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _cultureOptions.map((culture) {
                          final isSelected = _selectedCulture.contains(culture);
                          return FilterChip(
                            label: Text(culture),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedCulture.add(culture);
                                } else {
                                  _selectedCulture.remove(culture);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Benefits
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Benefits',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _benefitOptions.map((benefit) {
                          final isSelected = _selectedBenefits.contains(benefit);
                          return FilterChip(
                            label: Text(benefit),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedBenefits.add(benefit);
                                } else {
                                  _selectedBenefits.remove(benefit);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _saveProfile,
                isLoading: _isLoading,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}