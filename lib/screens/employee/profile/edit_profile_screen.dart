import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:jobconnect/widgets/custom_button.dart';
import 'package:jobconnect/providers/auth_provider.dart';
import 'package:jobconnect/utils/validators.dart';
import 'package:jobconnect/utils/permission_helper.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  
  File? _profileImage;
  bool _isLoading = false;
  List<String> _selectedSkills = [];
  List<String> _selectedInterests = [];

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
    'Machine Learning',
    'Data Science',
  ];

  final List<String> _availableInterests = [
    'Mobile Development',
    'Web Development',
    'UI/UX Design',
    'Machine Learning',
    'Cloud Computing',
    'DevOps',
    'Data Science',
    'Product Management',
    'Project Management',
    'Quality Assurance',
    'Cyber Security',
    'Blockchain',
    'IoT',
    'AR/VR',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _locationController.text = user.location ?? '';
      _bioController.text = user.bio ?? '';
      _selectedSkills = List.from(user.skills);
      _selectedInterests = List.from(user.interests);
    }
  }

  Future<void> _pickImage() async {
    // Request permission first
    bool hasPermission = await PermissionHelper.checkAndRequestPermission(
      permission: Permission.photos,
      permissionName: 'Photos',
      feature: 'uploading profile pictures',
      context: context,
    );

    if (!hasPermission) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    // Request camera permission first
    bool hasPermission = await PermissionHelper.checkAndRequestPermission(
      permission: Permission.camera,
      permissionName: 'Camera',
      feature: 'taking profile pictures',
      context: context,
    );

    if (!hasPermission) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Current Photo'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _profileImage = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Upload profile image if changed
      String? photoUrl;
      if (_profileImage != null) {
        photoUrl = await authProvider.updateProfileImage(_profileImage!);
      }

      // Update user data
      await authProvider.updateUserData({
        'displayName': _nameController.text,
        'phoneNumber': _phoneController.text,
        'location': _locationController.text,
        'bio': _bioController.text,
        'skills': _selectedSkills,
        'interests': _selectedInterests,
        if (photoUrl != null) 'photoURL': photoUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null) as ImageProvider?,
                      child: _profileImage == null && user?.photoURL == null
                          ? Text(
                              user?.displayName?[0].toUpperCase() ?? 'U',
                              style: TextStyle(
                                fontSize: 40,
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceDialog,
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

              // Personal Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: Validators.validateName,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Email (read-only)
                      TextFormField(
                        initialValue: user?.email ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email_outlined),
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        enabled: !_isLoading,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Bio
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About Me',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          hintText: 'Tell us about yourself...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        enabled: !_isLoading,
                        validator: (value) => Validators.validateDescription(
                          value,
                          field: 'Bio',
                          required: false,
                          maxLength: 500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skills
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Skills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Interests
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Interests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableInterests.map((interest) {
                          final isSelected = _selectedInterests.contains(interest);
                          return FilterChip(
                            label: Text(interest),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInterests.add(interest);
                                } else {
                                  _selectedInterests.remove(interest);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      if (_selectedInterests.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Selected: ${_selectedInterests.length} interests',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Social Links
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Social Links',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      // LinkedIn
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'LinkedIn Profile',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 12),

                      // GitHub
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'GitHub Profile',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 12),

                      // Portfolio
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Portfolio Website',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        enabled: !_isLoading,
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