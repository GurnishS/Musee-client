import 'package:musee/core/common/cubit/app_user_cubit.dart';
import 'package:musee/features/auth/presentation/pages/sign_in_page.dart';
import 'package:musee/features/auth/presentation/pages/sign_up_page.dart';
import 'package:musee/features/user__dashboard/presentation/pages/user_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class AppGoRouter {
  static GoRouter createRouter(AppUserCubit appUserCubit) {
    return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: '/',
      refreshListenable: AppUserChangeNotifier(appUserCubit),
      redirect: (context, state) {
        final isAuthenticated = appUserCubit.state is AppUserLoggedIn;
        if (kDebugMode) debugPrint("Auth:|$isAuthenticated");

        final intendedLocation = state.uri.toString();

        final isGoingToSignIn = intendedLocation.startsWith('/sign-in');
        final isGoingToSignUp = intendedLocation.startsWith('/sign-up');

        if (isAuthenticated) {
          return intendedLocation;
        }

        if (!isAuthenticated && !isGoingToSignIn && !isGoingToSignUp) {
          return '/sign-in?redirect=${Uri.encodeComponent(intendedLocation)}';
        }

        if (isAuthenticated && isGoingToSignIn) {
          final redirectUri = state.uri.queryParameters['redirect'] ?? '/';
          return redirectUri;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'user_dashboard',
          builder: (context, state) => UserDashboard(),
        ),
        GoRoute(
          path: '/sign-in',
          name: 'sign-in',
          builder: (context, state) {
            final redirectUrl =
                state.uri.queryParameters['redirect'] ?? '/dashboard';
            final newSignUp =
                state.uri.queryParameters['new-sign-up'] == 'true';
            return SignInPage(redirectUrl: redirectUrl, newSignUp: newSignUp);
          },
        ),
        GoRoute(
          path: '/sign-up',
          name: 'sign-up',
          builder: (context, state) {
            final redirectUrl =
                state.uri.queryParameters['redirect'] ?? '/dashboard';
            return SignUpPage(redirectUrl: redirectUrl);
          },
        ),

        GoRoute(
          path: '/test',
          name: 'test',
          builder: (context, state) {
            return SignUpPage(redirectUrl: '/dashboard');
          },
        ),
      ],
      errorBuilder: (context, state) => const ErrorPage(),
    );
  }
}

// Custom ChangeNotifier to listen to AppUserCubit state changes
class AppUserChangeNotifier extends ChangeNotifier {
  final AppUserCubit _appUserCubit;
  late final StreamSubscription _subscription;

  AppUserChangeNotifier(this._appUserCubit) {
    _subscription = _appUserCubit.stream.listen((_) {
      // Use addPostFrameCallback to prevent setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if the notifier is still valid before calling notifyListeners
        if (!_subscription.isPaused) {
          notifyListeners();
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              '404 - Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
