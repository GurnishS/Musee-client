import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musee/core/common/cubit/app_user_cubit.dart';
import 'package:musee/core/common/widgets/bottom_nav_bar.dart';
import 'package:musee/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:musee/features/user__dashboard/presentation/widgets/horizontal_media_section.dart';
import 'package:musee/features/user__dashboard/presentation/widgets/media_card.dart';
import 'package:musee/features/user__dashboard/presentation/widgets/section_header.dart';
import 'package:go_router/go_router.dart';
import 'package:musee/core/common/navigation/routes.dart';
import 'package:musee/core/common/entities/user.dart';

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
    return Scaffold(
      bottomNavigationBar: BottomNavBar(selectedIndex: 0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isCompact = width < 700;

            // Filler data for sections
            final recentlyPlayed = <MediaItem>[
              MediaItem(
                title: 'Supreme',
                subtitle: 'Album',
                imageUrl: 'https://picsum.photos/seed/supreme/300/300',
                icon: Icons.album,
                onTap: () =>
                    context.go('/albums/a06af84f-19b7-4688-949a-e7151460bff5'),
              ),
              ...List.generate(
                12,
                (i) => MediaItem(
                  title: 'Track #${i + 1}',
                  subtitle: 'Artist ${String.fromCharCode(65 + (i % 26))}',
                  imageUrl: i % 3 == 0
                      ? null
                      : 'https://picsum.photos/seed/rp$i/300/300',
                  icon: Icons.audiotrack,
                ),
              ),
            ];
            final madeForYou = List.generate(
              8,
              (i) => MediaItem(
                title: 'Daily Mix ${i + 1}',
                subtitle: 'Personalized playlist',
                imageUrl: i % 2 == 0
                    ? 'https://picsum.photos/seed/mfy$i/300/300'
                    : null,
                icon: Icons.queue_music,
              ),
            );
            final trending = List.generate(
              10,
              (i) => MediaItem(
                title: 'Trending ${i + 1}',
                subtitle: 'Hot now',
                imageUrl: 'https://picsum.photos/seed/tr$i/300/300',
                icon: Icons.trending_up,
              ),
            );

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: _HeaderBar(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _HeroBanner(),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: isCompact ? 8 : 12)),
                SliverToBoxAdapter(
                  child: HorizontalMediaSection(
                    title: 'Recently played',
                    items: recentlyPlayed,
                    onSeeAll: () {},
                    cardWidth: isCompact ? 140 : 160,
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: isCompact ? 4 : 8)),
                SliverToBoxAdapter(
                  child: SectionHeader(title: 'Made for you', onSeeAll: () {}),
                ),
                _GridSection(items: madeForYou),
                SliverToBoxAdapter(child: SizedBox(height: isCompact ? 4 : 8)),
                SliverToBoxAdapter(
                  child: SectionHeader(title: 'Trending now', onSeeAll: () {}),
                ),
                _GridSection(items: trending),
                SliverToBoxAdapter(
                  child: SizedBox(height: isCompact ? 24 : 32),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AppUserCubit, AppUserState>(
                builder: (context, state) {
                  final name = state is AppUserLoggedIn
                      ? state.user.name
                      : 'There';
                  return Text(
                    'Good day, $name',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              Text(
                'Let\'s discover some music for you',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.notifications_none),
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 8),
        // Quick access to Admin Home if the current user is an admin
        BlocBuilder<AppUserCubit, AppUserState>(
          builder: (context, state) {
            final isAdmin =
                state is AppUserLoggedIn &&
                state.user.userType == UserType.admin;
            if (!isAdmin) return const SizedBox.shrink();
            return IconButton.filledTonal(
              tooltip: 'Admin home',
              onPressed: () => context.go(Routes.adminDashboard),
              icon: const Icon(Icons.admin_panel_settings),
            );
          },
        ),
        const SizedBox(width: 8),
        BlocBuilder<AppUserCubit, AppUserState>(
          builder: (context, state) {
            final isAdmin =
                state is AppUserLoggedIn &&
                state.user.userType == UserType.admin;
            return PopupMenuButton<String>(
              icon: const CircleAvatar(child: Icon(Icons.person)),
              onSelected: (value) {
                switch (value) {
                  case 'admin':
                    context.go(Routes.adminDashboard);
                    break;
                  case 'logout':
                    context.read<AuthBloc>().add(AuthLogout());
                    context.read<AppUserCubit>().updateUser(null);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'profile', child: Text('Profile')),
                const PopupMenuItem(value: 'settings', child: Text('Settings')),
                if (isAdmin)
                  const PopupMenuItem(
                    value: 'admin',
                    child: Text('Open admin dashboard'),
                  ),
                const PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = LinearGradient(
      colors: [
        theme.colorScheme.primary.withOpacity(0.18),
        theme.colorScheme.secondary.withOpacity(0.12),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Here\'s your daily mix and top picks based on your recent listening.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _QuickChip(label: 'Focus'),
                    _QuickChip(label: 'Chill'),
                    _QuickChip(label: 'Workout'),
                    _QuickChip(label: 'Party'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 96,
            height: 96,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: theme.colorScheme.primary.withOpacity(0.15),
                child: const Icon(Icons.graphic_eq, size: 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  const _QuickChip({required this.label});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(label),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }
}

class _GridSection extends StatelessWidget {
  final List<MediaItem> items;
  const _GridSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.crossAxisExtent;
          int crossAxisCount;
          if (w < 400) {
            crossAxisCount = 2;
          } else if (w < 700) {
            crossAxisCount = 3;
          } else if (w < 1000) {
            crossAxisCount = 4;
          } else {
            crossAxisCount = 6;
          }
          // Compute a safer childAspectRatio so MediaCard (square art + text)
          // has enough vertical space and doesn't overflow in short grids.
          const double spacing = 12; // matches main/cross spacing
          final double tileWidth =
              (w - (spacing * (crossAxisCount - 1))) / crossAxisCount;
          const double extraTextHeight = 52; // title+subtitle+gaps+padding
          final double computedRatio =
              tileWidth / (tileWidth + extraTextHeight);
          final double aspectRatio = computedRatio.clamp(0.65, 0.85);

          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final item = items[index];
              return MediaCard(
                title: item.title,
                subtitle: item.subtitle,
                imageUrl: item.imageUrl,
                fallbackIcon: item.icon,
              );
            }, childCount: items.length),
          );
        },
      ),
    );
  }
}
