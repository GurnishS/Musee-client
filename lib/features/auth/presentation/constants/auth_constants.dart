import 'package:flutter/material.dart';

/// Constants used across authentication pages
class AuthConstants {
  // Animation durations
  static const Duration mainAnimationDuration = Duration(milliseconds: 800);
  static const Duration staggerAnimationDuration = Duration(milliseconds: 900);

  // Layout breakpoints
  static const double largeScreenBreakpoint = 800.0;

  // Spacing
  static const double defaultPadding = 24.0;
  static const double largePadding = 32.0;
  static const double extraLargePadding = 48.0;

  // Border radius
  static const double defaultBorderRadius = 16.0;
  static const double inputBorderRadius = 100.0;

  // Icon sizes
  static const double iconContainerSize = 56.0;
  static const double iconSize = 16.0;

  // Form validation messages
  static const String emptyFieldsMessage = 'Please fill in all fields';
  static const String emailSentMessage = 'A verification link has been sent to';
  static const String verificationInstructions =
      'Click on the verification link to continue to the next step';
  static const String resendEmailText = "Didn't receive the email? Resend";

  // Animation curves
  static const Curve fadeInCurve = Curves.easeOut;
  static const Curve slideInCurve = Curves.easeOutCubic;
  static const Curve elasticCurve = Curves.easeOutQuart;
}

/// Reusable input border styles
class AuthInputBorders {
  static const OutlineInputBorder defaultBorder = OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF757575)),
    borderRadius: BorderRadius.all(
      Radius.circular(AuthConstants.inputBorderRadius),
    ),
  );

  static OutlineInputBorder focusedBorder(BuildContext context) =>
      defaultBorder.copyWith(
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      );
}

/// Text styles used in authentication
class AuthTextStyles {
  static TextStyle title(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle subtitle(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static TextStyle description(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
    fontSize: 16,
  );

  static TextStyle hint(BuildContext context) =>
      TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(200));

  static TextStyle link(BuildContext context) => TextStyle(
    color: Theme.of(context).colorScheme.primary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}

/// Button styles
class AuthButtonStyles {
  static ButtonStyle primaryButton(BuildContext context) =>
      ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        minimumSize: const Size(double.infinity, 48),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AuthConstants.defaultBorderRadius),
          ),
        ),
      );
}
