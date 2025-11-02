class ValidationHelper {
  // Required field validation
  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
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
      return 'Password must be at least 8 characters long';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    
    final phoneRegex = RegExp(r'^[+]?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (!RegExp(r"^[a-zA-Z\s\-\']+$").hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  // Number validation
  static String? validateNumber(
    String? value, {
    double? min,
    double? max,
    bool allowDecimals = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    
    final number = allowDecimals 
        ? double.tryParse(value.trim())
        : int.tryParse(value.trim())?.toDouble();
    
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (!allowDecimals && number != number.roundToDouble()) {
      return 'Please enter a whole number';
    }

    if (min != null && number < min) {
      return 'Number must be at least $min';
    }

    if (max != null && number > max) {
      return 'Number must be no more than $max';
    }

    return null;
  }

  // Location validation
  static String? validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Location is required';
    }
    
    if (value.trim().length < 2) {
      return 'Location must be at least 2 characters long';
    }
    
    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'URL is required';
    }
    
    final urlRegex = RegExp(r'^https?://.+');
    if (!urlRegex.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Generic text length validation
  static String? validateLength(
    String? value, {
    int? minLength,
    int? maxLength,
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    
    final trimmedValue = value.trim();
    final field = fieldName ?? 'Field';
    
    if (minLength != null && trimmedValue.length < minLength) {
      return '$field must be at least $minLength characters long';
    }
    
    if (maxLength != null && trimmedValue.length > maxLength) {
      return '$field must be no more than $maxLength characters long';
    }
    
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  // File size validation (in bytes)
  static String? validateFileSize(
    int? fileSizeBytes, {
    int maxSizeBytes = 10 * 1024 * 1024, // 10MB default
  }) {
    if (fileSizeBytes == null) {
      return 'File is required';
    }
    
    if (fileSizeBytes > maxSizeBytes) {
      final maxSizeMB = (maxSizeBytes / (1024 * 1024)).toStringAsFixed(1);
      return 'File size must be less than ${maxSizeMB}MB';
    }
    
    return null;
  }

  // Multiple validation helper
  static String? validateMultiple(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
