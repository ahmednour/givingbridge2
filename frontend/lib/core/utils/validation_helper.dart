import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Helper class for form validation with localized error messages
class ValidationHelper {
  /// Validate required field
  static String? validateRequired(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    return null;
  }

  /// Validate email format
  static String? validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.emailRequired;
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.emailInvalid;
    }
    
    if (value.length > 254) {
      return l10n.emailTooLong;
    }
    
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value, AppLocalizations l10n, {
    int minLength = 6,
    bool requireUppercase = false,
    bool requireLowercase = false,
    bool requireNumber = false,
    bool requireSpecialChar = false,
  }) {
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    
    if (value.length < minLength) {
      return l10n.passwordTooShort;
    }
    
    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return l10n.passwordMustContainUppercase;
    }
    
    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return l10n.passwordMustContainLowercase;
    }
    
    if (requireNumber && !value.contains(RegExp(r'[0-9]'))) {
      return l10n.passwordMustContainNumber;
    }
    
    if (requireSpecialChar && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return l10n.passwordMustContainSpecialChar;
    }
    
    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
    String? value, 
    String? originalPassword, 
    AppLocalizations l10n
  ) {
    if (value == null || value.isEmpty) {
      return l10n.fieldRequired;
    }
    
    if (value != originalPassword) {
      return l10n.passwordsDoNotMatch;
    }
    
    return null;
  }

  /// Validate name
  static String? validateName(String? value, AppLocalizations l10n, {
    int minLength = 2,
    int maxLength = 50,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n.nameRequired;
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < minLength) {
      return l10n.nameTooShort;
    }
    
    if (trimmedValue.length > maxLength) {
      return l10n.nameTooLong;
    }
    
    // Allow Arabic, English letters, spaces, and common name characters
    final nameRegex = RegExp(r'^[\u0600-\u06FFa-zA-Z\s\-\'\.]+$');
    if (!nameRegex.hasMatch(trimmedValue)) {
      return l10n.nameInvalidCharacters;
    }
    
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.phoneRequired;
    }
    
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (cleanPhone.length < 8) {
      return l10n.phoneTooShort;
    }
    
    if (cleanPhone.length > 15) {
      return l10n.phoneTooLong;
    }
    
    // Basic phone number validation (international format)
    final phoneRegex = RegExp(r'^\+?[1-9]\d{7,14}$');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      return l10n.phoneInvalid;
    }
    
    return null;
  }

  /// Validate donation title
  static String? validateDonationTitle(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.titleRequired;
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 3) {
      return l10n.titleTooShort;
    }
    
    if (trimmedValue.length > 100) {
      return l10n.titleTooLong;
    }
    
    return null;
  }

  /// Validate donation description
  static String? validateDonationDescription(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.descriptionRequired;
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 10) {
      return l10n.descriptionTooShort;
    }
    
    if (trimmedValue.length > 1000) {
      return l10n.descriptionTooLong;
    }
    
    return null;
  }

  /// Validate location
  static String? validateLocation(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.locationRequired;
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < 2) {
      return l10n.locationTooShort;
    }
    
    if (trimmedValue.length > 100) {
      return l10n.locationTooLong;
    }
    
    return null;
  }

  /// Validate quantity
  static String? validateQuantity(String? value, AppLocalizations l10n, {
    int min = 1,
    int max = 1000,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n.quantityRequired;
    }
    
    final quantity = int.tryParse(value.trim());
    if (quantity == null) {
      return l10n.quantityInvalid;
    }
    
    if (quantity < min) {
      return l10n.quantityTooSmall;
    }
    
    if (quantity > max) {
      return l10n.quantityTooLarge;
    }
    
    return null;
  }

  /// Validate message
  static String? validateMessage(String? value, AppLocalizations l10n, {
    int minLength = 5,
    int maxLength = 500,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? l10n.messageRequired : null;
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length < minLength) {
      return l10n.messageTooShort;
    }
    
    if (trimmedValue.length > maxLength) {
      return l10n.messageTooLong;
    }
    
    return null;
  }

  /// Validate dropdown selection
  static String? validateSelection(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return l10n.pleaseSelectOption;
    }
    return null;
  }

  /// Validate number input
  static String? validateNumber(String? value, AppLocalizations l10n, {
    double? min,
    double? max,
    bool allowDecimals = true,
    bool required = true,
  }) {
    if (value == null || value.trim().isEmpty) {
      return required ? l10n.pleaseEnterNumber : null;
    }
    
    final number = allowDecimals 
        ? double.tryParse(value.trim())
        : int.tryParse(value.trim())?.toDouble();
    
    if (number == null) {
      return l10n.invalidInput;
    }
    
    if (!allowDecimals && number != number.roundToDouble()) {
      return l10n.mustBeWholeNumber;
    }
    
    if (number < 0) {
      return l10n.mustBePositiveNumber;
    }
    
    if (min != null && number < min) {
      return l10n.numberTooSmall;
    }
    
    if (max != null && number > max) {
      return l10n.numberTooLarge;
    }
    
    return null;
  }

  /// Get localized error message for common errors
  static String getErrorMessage(String errorKey, AppLocalizations l10n) {
    switch (errorKey) {
      case 'network_error':
        return l10n.networkError;
      case 'server_error':
        return l10n.serverError;
      case 'timeout_error':
        return l10n.timeoutError;
      case 'connection_error':
        return l10n.connectionError;
      case 'unknown_error':
        return l10n.unknownError;
      case 'operation_failed':
        return l10n.operationFailed;
      case 'access_denied':
        return l10n.accessDenied;
      case 'unauthorized':
        return l10n.unauthorized;
      case 'forbidden':
        return l10n.forbidden;
      case 'not_found':
        return l10n.notFound;
      case 'already_exists':
        return l10n.alreadyExists;
      case 'validation_error':
        return l10n.validationError;
      case 'session_expired':
        return l10n.sessionExpired;
      case 'account_locked':
        return l10n.accountLocked;
      case 'account_disabled':
        return l10n.accountDisabled;
      case 'verification_required':
        return l10n.verificationRequired;
      case 'verification_failed':
        return l10n.verificationFailed;
      case 'too_many_attempts':
        return l10n.tooManyAttempts;
      case 'service_unavailable':
        return l10n.serviceUnavailable;
      case 'maintenance_mode':
        return l10n.maintenanceMode;
      default:
        return l10n.unknownError;
    }
  }

  /// Get localized success message
  static String getSuccessMessage(String successKey, AppLocalizations l10n) {
    switch (successKey) {
      case 'operation_successful':
        return l10n.operationSuccessful;
      case 'save_successful':
        return l10n.saveSuccessful;
      case 'update_successful':
        return l10n.updateSuccessful;
      case 'delete_successful':
        return l10n.deleteSuccessful;
      case 'create_successful':
        return l10n.createSuccessful;
      case 'login_successful':
        return l10n.loginSuccessful;
      case 'registration_successful':
        return l10n.registrationSuccessful;
      case 'verification_successful':
        return l10n.verificationSuccessful;
      case 'password_changed':
        return l10n.passwordChanged;
      case 'profile_updated':
        return l10n.profileUpdated;
      case 'settings_updated':
        return l10n.settingsUpdated;
      case 'message_sent':
        return l10n.messageSent;
      case 'request_sent':
        return l10n.requestSent;
      default:
        return l10n.operationSuccessful;
    }
  }
}