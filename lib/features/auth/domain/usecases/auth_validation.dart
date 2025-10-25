/// Validation utilities for authentication
class AuthValidation {
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int maxNameLength = 100;

  /// Email regex pattern for basic validation
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates email format
  static String? validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'Email cannot be empty';
    }

    final trimmedEmail = email.trim();
    if (!_emailRegex.hasMatch(trimmedEmail)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }

    if (password.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }

    if (password.length > maxPasswordLength) {
      return 'Password must be less than $maxPasswordLength characters';
    }

    return null;
  }

  /// Validates name
  static String? validateName(String name) {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return 'Name cannot be empty';
    }

    if (trimmedName.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (trimmedName.length > maxNameLength) {
      return 'Name must be less than $maxNameLength characters';
    }

    return null;
  }

  /// Normalizes email by trimming and converting to lowercase
  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  /// Normalizes name by trimming whitespace
  static String normalizeName(String name) {
    return name.trim();
  }
}
