import 'package:musee/core/common/cubit/app_user_cubit.dart';
import 'package:musee/core/common/entities/user.dart';
import 'package:musee/core/common/navigation/routes.dart';
import 'package:musee/features/admin__dashboard/presentation/pages/admin_dashboard.dart';
import 'package:musee/features/auth/presentation/pages/sign_in_page.dart';
import 'package:musee/features/auth/presentation/pages/sign_up_page.dart';
import 'package:musee/features/user__dashboard/presentation/pages/user_dashboard.dart';
import 'package:musee/features/admin_users/presentation/pages/admin_users_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musee/features/admin_users/presentation/bloc/admin_users_bloc.dart';
import 'package:musee/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class AppGoRouter {
  static GoRouter createRouter(AppUserCubit appUserCubit) {
    final isAdmin =
        appUserCubit.state is AppUserLoggedIn &&
        (appUserCubit.state as AppUserLoggedIn).user.userType == UserType.admin;

    return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: isAdmin ? Routes.adminDashboard : Routes.dashboard,
      refreshListenable: AppUserChangeNotifier(appUserCubit),
      redirect: (context, state) {
        final isAuthenticated = appUserCubit.state is AppUserLoggedIn;

        if (kDebugMode) debugPrint("Auth:|$isAuthenticated $isAdmin");

        final intendedLocation = state.uri.toString();

        final isGoingToSignIn = intendedLocation.startsWith(Routes.signIn);
        final isGoingToSignUp = intendedLocation.startsWith(Routes.signUp);

        if (isAuthenticated && isAdmin) {
          return intendedLocation;
        } else if (isAuthenticated && !isAdmin) {
          if (intendedLocation.startsWith(Routes.adminDashboard)) {
            return Routes.forbidden;
          }
          return intendedLocation;
        }

        if (!isAuthenticated && !isGoingToSignIn && !isGoingToSignUp) {
          return '${Routes.signIn}?redirect=${Uri.encodeComponent(intendedLocation)}';
        }

        if (isAuthenticated && isGoingToSignIn) {
          final redirectUri =
              state.uri.queryParameters['redirect'] ?? Routes.root;
          return redirectUri;
        }

        return null;
      },
      routes: [
        // Legacy root -> redirect to canonical dashboard
        GoRoute(
          path: Routes.root,
          redirect: (context, state) => Routes.dashboard,
        ),

        GoRoute(
          path: Routes.dashboard,
          name: 'user_dashboard',
          builder: (context, state) => UserDashboard(),
        ),

        GoRoute(
          path: Routes.adminDashboard,
          name: 'admin_dashboard',
          builder: (context, state) => AdminDashboard(),
        ),

        GoRoute(
          path: Routes.adminUsers,
          name: 'admin_users',
          builder: (context, state) => BlocProvider(
            create: (_) => serviceLocator<AdminUsersBloc>(),
            child: const AdminUsersPage(),
          ),
        ),

        GoRoute(
          path: Routes.signIn,
          name: 'sign-in',
          builder: (context, state) {
            final redirectUrl =
                state.uri.queryParameters['redirect'] ?? Routes.dashboard;
            final newSignUp =
                state.uri.queryParameters['new-sign-up'] == 'true';
            return SignInPage(redirectUrl: redirectUrl, newSignUp: newSignUp);
          },
        ),

        GoRoute(
          path: Routes.signUp,
          name: 'sign-up',
          builder: (context, state) {
            final redirectUrl =
                state.uri.queryParameters['redirect'] ?? Routes.dashboard;
            return SignUpPage(redirectUrl: redirectUrl);
          },
        ),

        GoRoute(
          path: Routes.forbidden,
          name: 'forbidden',
          builder: (context, state) => const ForbiddenPage(),
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

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              '403 - Forbidden',
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
