import 'package:flutter/material.dart';
import 'package:musee/features/auth/domain/usecases/auth_validation.dart';

/// Form validation utilities for authentication
class AuthFormValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    return AuthValidation.validateEmail(value);
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return AuthValidation.validatePassword(value);
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return AuthValidation.validateName(value);
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}

/// Form data container for authentication forms
class AuthFormData {
  final String email;
  final String password;
  final String? name;

  const AuthFormData({required this.email, required this.password, this.name});

  bool get isValid {
    final emailError = AuthFormValidator.validateEmail(email);
    final passwordError = AuthFormValidator.validatePassword(password);
    final nameError = name != null
        ? AuthFormValidator.validateName(name!)
        : null;

    return emailError == null && passwordError == null && nameError == null;
  }

  bool get hasAllFields {
    return email.isNotEmpty &&
        password.isNotEmpty &&
        (name == null || name!.isNotEmpty);
  }
}

/// Helper for managing form controllers
class AuthFormControllers {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  AuthFormData get formData => AuthFormData(
    email: emailController.text.trim(),
    password: passwordController.text,
    name: nameController.text.trim().isEmpty
        ? null
        : nameController.text.trim(),
  );

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
  }

  void clear() {
    emailController.clear();
    passwordController.clear();
    nameController.clear();
  }
}
