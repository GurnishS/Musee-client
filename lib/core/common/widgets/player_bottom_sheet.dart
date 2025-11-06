import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:musee/core/player/player_cubit.dart';
import 'package:musee/core/player/player_state.dart';

/// Shows the full-screen player bottom sheet, styled similar to Spotify.
Future<void> showPlayerBottomSheet(
  BuildContext context, {
  required String audioUrl,
  String? title,
  String? artist,
  String? album,
  String? imageUrl,
  Map<String, String>? headers,
}) async {
  final track = PlayerTrack(
    url: audioUrl,
    title: title ?? 'Unknown Title',
    artist: artist ?? 'Unknown Artist',
    album: album,
    imageUrl: imageUrl,
    headers: headers,
  );
  // Avoid restarting playback when opening the sheet from the mini-player
  // if the same track is already loaded. Only start playback when it's
  // a different track (e.g., starting from album list).
  final cubit = GetIt.I<PlayerCubit>();
  final currentUrl = cubit.state.track?.url;
  final isDifferentTrack = currentUrl == null || currentUrl != audioUrl;
  if (isDifferentTrack) {
    await cubit.playTrack(track);
  }

  await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return BlocProvider.value(
        value: cubit,
        child: const _PlayerBackdrop(child: _PlayerSheetBody()),
      );
    },
  );
}

/// Backdrop with a subtle vertical gradient based on theme.
class _PlayerBackdrop extends StatelessWidget {
  final Widget child;
  const _PlayerBackdrop({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final top = Color.alphaBlend(cs.primary.withValues(alpha: 0.08), cs.surface);
    final mid = Color.alphaBlend(cs.secondary.withValues(alpha: 0.06), cs.surface);
    final bottom = cs.surface;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, mid, bottom],
        ),
      ),
      child: child,
    );
  }
}

class _PlayerSheetBody extends StatefulWidget {
  const _PlayerSheetBody();

  @override
  State<_PlayerSheetBody> createState() => _PlayerSheetBodyState();
}

class _PlayerSheetBodyState extends State<_PlayerSheetBody> {
  String _fmt(Duration d) {
    final total = d.inSeconds;
    final m = (total ~/ 60).toString();
    final sec = (total % 60).toString().padLeft(2, '0');
    return "$m:$sec";
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).viewPadding.top;
    final topGap = topInset > 0
        ? 12.0
        : 0.0; // extra breathing room under notches/dynamic island

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocBuilder<PlayerCubit, PlayerViewState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          final title = state.track?.title ?? 'Unknown Title';
          final artist = state.track?.artist ?? 'Unknown Artist';
          final album = state.track?.album ?? '';
          final imageUrl = state.track?.imageUrl;
          final pos = state.position;
          final dur = state.duration.inMilliseconds > 0
              ? state.duration
              : const Duration(seconds: 1);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Automatically add a small dynamic margin below system overlays
              if (topGap > 0) SizedBox(height: topGap),
              // Header
              Row(
                children: [
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          album.isEmpty ? 'NOW PLAYING' : 'PLAYING FROM ALBUM',
                          style: theme.textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.labelSmall?.color
                                ?.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          album.isEmpty ? 'Musee' : album,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'More',
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Artwork (large square)
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: (imageUrl?.isNotEmpty ?? false)
                          ? Image.network(
                              imageUrl!,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium,
                              headers: state.track?.headers,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.6,
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                                (progress.expectedTotalBytes!)
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stack) {
                                return Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.music_note_rounded,
                                    size: 64,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: theme.colorScheme.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.music_note_rounded,
                                size: 64,
                              ),
                            ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title + Add
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          artist,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.textTheme.bodyLarge?.color
                                ?.withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Add to library',
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress + times
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  min: 0,
                  max: dur.inMilliseconds.toDouble(),
                  value: pos.inMilliseconds
                      .clamp(0, dur.inMilliseconds)
                      .toDouble(),
                  onChanged: (v) => context.read<PlayerCubit>().seek(
                    Duration(milliseconds: v.round()),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_fmt(pos), style: theme.textTheme.labelMedium),
                  Text(_fmt(dur), style: theme.textTheme.labelMedium),
                ],
              ),

              const SizedBox(height: 8),

              // Controls
              Row(
                children: [
                  IconButton(
                    tooltip: 'Enhance / Shuffle',
                    onPressed: () {},
                    icon: const Icon(Icons.auto_awesome_rounded),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Previous',
                    onPressed: () => context.read<PlayerCubit>().previous(),
                    icon: const Icon(Icons.skip_previous_rounded),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: state.buffering
                          ? null
                          : () => context.read<PlayerCubit>().togglePlayPause(),
                      child: state.playing
                          ? const Icon(Icons.pause_rounded, size: 42)
                          : state.buffering
                          ? const SizedBox(
                              width: 42,
                              height: 42,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : const Icon(Icons.play_arrow_rounded, size: 42),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Next',
                    onPressed: () => context.read<PlayerCubit>().next(userInitiated: true),
                    icon: const Icon(Icons.skip_next_rounded),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Sleep timer',
                    onPressed: () {},
                    icon: const Icon(Icons.timer_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Footer actions
              Row(
                children: [
                  IconButton(
                    tooltip: 'Devices',
                    onPressed: () {},
                    icon: const Icon(Icons.cast_rounded),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Share',
                    onPressed: () {},
                    icon: const Icon(Icons.share_rounded),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Lyrics / Queue',
                    onPressed: () {
                      final cubit = context.read<PlayerCubit>();
                      showModalBottomSheet(
                        context: context,
                        useRootNavigator: true,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => BlocProvider.value(
                          value: cubit,
                          child: const _QueueSheet(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.queue_music_rounded),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
            ],
          );
        },
      ),
    );
  }
}

class _QueueSheet extends StatelessWidget {
  const _QueueSheet();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scroll) {
        return Material(
          color: theme.colorScheme.surface,
          elevation: 8,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Queue', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    ),
                    IconButton(
                      tooltip: 'Clear queue',
                      onPressed: () => context.read<PlayerCubit>().clearQueue(),
                      icon: const Icon(Icons.clear_all_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: BlocBuilder<PlayerCubit, PlayerViewState>(
                    builder: (context, state) {
                      final items = state.queue;
                      if (items.isEmpty) {
                        return const Center(child: Text('Your queue is empty'));
                      }
                      return ReorderableListView.builder(
                        scrollController: scroll,
                        itemCount: items.length,
                        onReorder: (from, to) {
                          // Flutter uses a different insertion index when moving down
                          final newIndex = to > from ? to - 1 : to;
                          context.read<PlayerCubit>().reorderQueue(from, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final q = items[index];
                          final playing = index == state.currentIndex;
                          return ListTile(
                            key: ValueKey(q.trackId),
                            leading: playing
                                ? const Icon(Icons.volume_up_rounded)
                                : Text('${index + 1}', style: theme.textTheme.labelLarge),
                            title: Text(q.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(q.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Remove',
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () => context.read<PlayerCubit>().removeFromQueue(q.trackId),
                                ),
                                const Icon(Icons.drag_handle_rounded),
                              ],
                            ),
                            onTap: () => context.read<PlayerCubit>().playFromQueueTrackId(q.trackId),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
