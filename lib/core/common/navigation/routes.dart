class Routes {
  // Primary user-facing dashboard
  static const String dashboard = '/dashboard';

  // Admin dashboard
  static const String adminDashboard = '/admin';
  static const String adminUsers = '/admin/users';

  // Authentication
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';

  // Forbidden / error
  static const String forbidden = '/forbidden';

  // Root (legacy) - redirect to dashboard
  static const String root = '/';
}
