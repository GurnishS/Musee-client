import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:musee/core/common/widgets/player_bottom_sheet.dart';
import 'package:musee/core/player/player_cubit.dart';
import 'package:musee/core/player/player_state.dart';

class FloatingPlayerPanel extends StatelessWidget {
  const FloatingPlayerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    final cubit = GetIt.I<PlayerCubit>();

    return BlocBuilder<PlayerCubit, PlayerViewState>(
      bloc: cubit,
      builder: (context, state) {
        final track = state.track;
        final hasTrack = track != null;
        final title = track?.title ?? 'Nothing playing';
        final artist = track?.artist ?? 'Tap to choose something';
        final artUrl = track?.imageUrl;
        final pos = state.position;
        final dur = state.duration;
        final progress = (dur.inMilliseconds > 0)
            ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return InkWell(
          onTap: hasTrack
              ? () {
                  final t = track; // non-null under hasTrack
                  showPlayerBottomSheet(
                    context,
                    audioUrl: t.url,
                    title: t.title,
                    artist: t.artist,
                    album: t.album,
                    imageUrl: t.imageUrl,
                    headers: t.headers,
                  );
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: artwork • title/artist • controls
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Artwork
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: artUrl == null
                            ? Container(
                                color: color.primary.withOpacity(0.15),
                                child: const Icon(Icons.music_note, size: 28),
                              )
                            : Ink.image(
                                image: NetworkImage(artUrl),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title / Artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Controls
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: hasTrack ? () {} : null,
                          tooltip: 'Previous',
                          icon: const Icon(Icons.skip_previous_rounded),
                        ),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: const CircleBorder(),
                            ),
                            onPressed: hasTrack
                                ? (state.buffering
                                      ? null
                                      : () => cubit.togglePlayPause())
                                : null,
                            child: state.playing
                                ? const Icon(Icons.pause_rounded, size: 24)
                                : state.buffering
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 28,
                                  ),
                          ),
                        ),
                        IconButton(
                          onPressed: hasTrack ? () {} : null,
                          tooltip: 'Next',
                          icon: const Icon(Icons.skip_next_rounded),
                        ),
                      ],
                    ),
                  ],
                ),

                // Progress bar + time codes
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: color.onSurface.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation(color.primary),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmt(pos), style: theme.textTheme.labelSmall),
                        Text(_fmt(dur), style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _fmt(Duration d) {
  final total = d.inSeconds;
  final m = (total ~/ 60).toString();
  final s = (total % 60).toString().padLeft(2, '0');
  return "$m:$s";
}
