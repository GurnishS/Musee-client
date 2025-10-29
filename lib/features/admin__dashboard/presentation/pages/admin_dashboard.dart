import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musee/core/common/navigation/routes.dart';
import 'package:musee/features/admin__dashboard/presentation/widgets/admin_sidebar.dart';
import 'package:musee/features/admin__dashboard/presentation/widgets/admin_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Open user dashboard',
            onPressed: () => context.go(Routes.dashboard),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      drawer: Drawer(child: AdminSidebar()),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final int crossAxisCount;
          if (w < 350) {
            crossAxisCount = 1;
          } else if (w < 600) {
            crossAxisCount = 2;
          } else if (w < 1000) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 4;
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top summary row
                // Top summary row: wraps on small widths to avoid overflow
                LayoutBuilder(
                  builder: (context, topConstraints) {
                    return Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        Text(
                          'Welcome back, Admin',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => context.go(Routes.dashboard),
                            icon: const Icon(Icons.person),
                            label: const Text('Browse app as user'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Cards grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      AdminCard(
                        title: 'Users',
                        subtitle: 'Manage all app users',
                        icon: Icons.people,
                        color: theme.colorScheme.primary,
                        onTap: () {
                          context.push(Routes.adminUsers);
                        },
                      ),
                      AdminCard(
                        title: 'Artists',
                        subtitle: 'Manage artists',
                        icon: Icons.mic,
                        color: theme.colorScheme.secondary,
                        onTap: () {
                          context.push(Routes.adminArtists);
                        },
                      ),
                      AdminCard(
                        title: 'Tracks',
                        subtitle: 'Manage tracks',
                        icon: Icons.music_note,
                        color: Colors.green,
                        onTap: () {
                          context.go('/admin/tracks');
                        },
                      ),
                      AdminCard(
                        title: 'Albums',
                        subtitle: 'Manage albums',
                        icon: Icons.album,
                        color: theme.colorScheme.secondary.withOpacity(0.85),
                        onTap: () {
                          context.push("/admin/albums");
                        },
                      ),
                      AdminCard(
                        title: 'Playlists',
                        subtitle: 'Manage playlists',
                        icon: Icons.queue_music,
                        color: Colors.teal,
                        onTap: () {},
                      ),
                      AdminCard(
                        title: 'Plans',
                        subtitle: 'Manage subscription plans',
                        icon: Icons.subscriptions,
                        color: Colors.indigo,
                        onTap: () {
                          context.go('/admin/plans');
                        },
                      ),
                      AdminCard(
                        title: 'Countries',
                        subtitle: 'Manage countries',
                        icon: Icons.public,
                        color: Colors.deepOrange,
                        onTap: () {
                          context.go('/admin/countries');
                        },
                      ),
                      AdminCard(
                        title: 'Regions',
                        subtitle: 'Manage regions',
                        icon: Icons.map,
                        color: Colors.purple,
                        onTap: () {
                          context.go('/admin/regions');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// AdminCard moved to widgets/admin_card.dart
