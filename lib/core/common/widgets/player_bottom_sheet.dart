import 'package:flutter/material.dart';

/// Shows the full-screen player bottom sheet, styled similar to Spotify.
Future<void> showPlayerBottomSheet(
  BuildContext context, {
  String? title,
  String? artist,
  String? album,
  String? imageUrl,
}) async {
  await showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return const _PlayerBackdrop(child: _PlayerSheetBody());
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
    final top = Color.alphaBlend(cs.primary.withOpacity(0.08), cs.surface);
    final mid = Color.alphaBlend(cs.secondary.withOpacity(0.06), cs.surface);
    final bottom = cs.surface;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, mid, bottom],
        ),
      ),
      child: SafeArea(top: true, bottom: true, child: child),
    );
  }
}

class _PlayerSheetBody extends StatefulWidget {
  const _PlayerSheetBody();

  @override
  State<_PlayerSheetBody> createState() => _PlayerSheetBodyState();
}

class _PlayerSheetBodyState extends State<_PlayerSheetBody> {
  double _position = 2; // seconds (demo)
  final double _duration = 165; // 2:45 (demo)

  String _fmt(double s) {
    final total = s.clamp(0, _duration).round();
    final m = (total ~/ 60).toString();
    final sec = (total % 60).toString().padLeft(2, '0');
    return "$m:$sec";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                      'PLAYING FROM ALBUM',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.labelSmall?.color?.withOpacity(
                          0.9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sicario',
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
                  child: Container(
                    color: cs.surfaceContainerHighest,
                    child: const FittedBox(
                      fit: BoxFit.cover,
                      child: Icon(Icons.music_note_rounded, size: 64),
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
                      'Aura',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Shubh',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.textTheme.bodyLarge?.color?.withOpacity(
                          0.85,
                        ),
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
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              min: 0,
              max: _duration,
              value: _position.clamp(0, _duration),
              onChanged: (v) => setState(() => _position = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_fmt(_position), style: theme.textTheme.labelMedium),
              Text(_fmt(_duration), style: theme.textTheme.labelMedium),
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
                onPressed: () {},
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
                  onPressed: () {},
                  child: const Icon(Icons.play_arrow_rounded, size: 42),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Next',
                onPressed: () {},
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
                onPressed: () {},
                icon: const Icon(Icons.queue_music_rounded),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 4),
        ],
      ),
    );
  }
}
