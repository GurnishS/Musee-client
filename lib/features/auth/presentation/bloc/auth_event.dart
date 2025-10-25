part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

/// Event for user sign up with email and password
final class AuthSignUp extends AuthEvent {
  final String email;
  final String password;
  final String name;

  AuthSignUp({required this.email, required this.password, required this.name})
    : assert(email.isNotEmpty, 'Email cannot be empty'),
      assert(password.isNotEmpty, 'Password cannot be empty'),
      assert(name.isNotEmpty, 'Name cannot be empty');
}

/// Event for user sign in with email and password
final class AuthSignIn extends AuthEvent {
  final String email;
  final String password;

  AuthSignIn({required this.email, required this.password})
    : assert(email.isNotEmpty, 'Email cannot be empty'),
      assert(password.isNotEmpty, 'Password cannot be empty');
}

/// Event for Google sign in
final class AuthSignInWithGoogle extends AuthEvent {}

/// Event to check if user is already logged in
final class AuthUserLoggedIn extends AuthEvent {}

/// Event to resend email verification
final class AuthResendEmailVerification extends AuthEvent {
  final String email;
  AuthResendEmailVerification(this.email)
    : assert(email.isNotEmpty, 'Email cannot be empty');
}

/// Event to check email verification status
final class AuthCheckEmailVerification extends AuthEvent {
  final String email;
  AuthCheckEmailVerification(this.email)
    : assert(email.isNotEmpty, 'Email cannot be empty');
}

/// Event for user logout
final class AuthLogout extends AuthEvent {}

/// Event to reset auth state to initial
final class ResetAuthState extends AuthEvent {}

// Event to toggle forget Password
final class PasswordResetEvent extends AuthEvent {}

/// Event to send password reset mail
final class AuthSendPasswordResetEmail extends AuthEvent {
  final String email;
  AuthSendPasswordResetEmail(this.email)
      : assert(email.isNotEmpty, 'Email cannot be empty');
}