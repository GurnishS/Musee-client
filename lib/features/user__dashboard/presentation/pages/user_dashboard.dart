import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musee/core/common/cubit/app_user_cubit.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint("UserDashboard initialized");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: BlocConsumer<AppUserCubit, AppUserState>(
            listener: (context, state) {
              if (state is AppUserInitial) {
                // Navigate to sign-in page if user is not logged in
                Navigator.of(context).pushReplacementNamed('/sign-in');
              }
            },
            builder: (context, state) {
              if (state is AppUserLoggedIn) {
                final user = state.user;
                return Text('Welcome, ${user.name} (${user.email})');
              } else if (state is AppUserLoading) {
                return const CircularProgressIndicator();
              } else {
                return const Text('Redirecting to sign-in...');
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        FloatingActionButton(
          onPressed: () {
            // Example action: Log out user
            context.read<AppUserCubit>().updateUser(null);
          },
          child: const Icon(Icons.logout),
        ),
      ],
    );
  }
}
