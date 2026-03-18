class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (value.length > 32) {
      return 'Password must be less than 32 characters';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value, {String field = 'Name'}) {
    if (value == null || value.isEmpty) {
      return '$field is required';
    }
    
    if (value.length < 2) {
      return '$field must be at least 2 characters';
    }
    
    if (value.length > 50) {
      return '$field must be less than 50 characters';
    }
    
    if (!value.contains(RegExp(r'^[a-zA-Z\s]+$'))) {
      return '$field can only contain letters and spaces';
    }
    
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'URL is required' : null;
    }
    
    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Number validation
  static String? validateNumber(String? value, {
    required String field,
    double? min,
    double? max,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? '$field is required' : null;
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return '$field must be at least $min';
    }
    
    if (max != null && number > max) {
      return '$field must be at most $max';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  // Salary validation
  static String? validateSalary(String? value, {String field = 'Salary'}) {
    if (value == null || value.isEmpty) {
      return null; // Salary is optional
    }
    
    final salary = double.tryParse(value);
    if (salary == null || salary <= 0) {
      return 'Please enter a valid salary amount';
    }
    
    if (salary > 1000000) {
      return 'Salary cannot exceed 1,000,000';
    }
    
    return null;
  }

  // Date validation
  static String? validateDate(DateTime? date, {
    String field = 'Date',
    DateTime? minDate,
    DateTime? maxDate,
    bool required = true,
  }) {
    if (date == null) {
      return required ? '$field is required' : null;
    }
    
    if (minDate != null && date.isBefore(minDate)) {
      return '$field cannot be before ${_formatDate(minDate)}';
    }
    
    if (maxDate != null && date.isAfter(maxDate)) {
      return '$field cannot be after ${_formatDate(maxDate)}';
    }
    
    return null;
  }

  // Experience years validation
  static String? validateExperience(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Experience is optional
    }
    
    final years = double.tryParse(value);
    if (years == null || years < 0) {
      return 'Please enter valid years of experience';
    }
    
    if (years > 50) {
      return 'Experience cannot exceed 50 years';
    }
    
    return null;
  }

  // Job title validation
  static String? validateJobTitle(String? value) {
    return validateName(value, field: 'Job title');
  }

  // Company name validation
  static String? validateCompanyName(String? value) {
    return validateName(value, field: 'Company name');
  }

  // Location validation
  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Location is required';
    }
    
    if (value.length < 2) {
      return 'Location must be at least 2 characters';
    }
    
    if (value.length > 100) {
      return 'Location must be less than 100 characters';
    }
    
    return null;
  }

  // Description validation
  static String? validateDescription(String? value, {
    String field = 'Description',
    int minLength = 10,
    int maxLength = 2000,
    bool required = true,
  }) {
    if (value == null || value.isEmpty) {
      return required ? '$field is required' : null;
    }
    
    if (value.length < minLength) {
      return '$field must be at least $minLength characters';
    }
    
    if (value.length > maxLength) {
      return '$field must be less than $maxLength characters';
    }
    
    return null;
  }

  // File validation
  static String? validateFile(String? fileName, {
    required List<String> allowedExtensions,
    int? maxSizeMB,
    bool required = true,
  }) {
    if (fileName == null || fileName.isEmpty) {
      return required ? 'File is required' : null;
    }
    
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'File type not allowed. Allowed: ${allowedExtensions.join(", ")}';
    }
    
    return null;
  }

  // Helper method to format date
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}