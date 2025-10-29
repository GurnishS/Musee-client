import 'package:flutter/material.dart';
import 'package:musee/core/common/widgets/player_bottom_sheet.dart';

class FloatingPlayerPanel extends StatelessWidget {
  const FloatingPlayerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    return InkWell(
      onTap: () {
        showPlayerBottomSheet(context);
      },
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
                  child: Container(
                    width: 64,
                    height: 64,
                    color: color.primary.withOpacity(0.15),
                    child: const Icon(Icons.music_note, size: 28),
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
                        'Aura',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Shubh',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.8,
                          ),
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
                      onPressed: () {},
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
                        onPressed: () {},
                        child: const Icon(Icons.play_arrow_rounded, size: 28),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      tooltip: 'Next',
                      icon: const Icon(Icons.skip_next_rounded),
                    ),
                  ],
                ),
              ],
            ),

            // Progress bar + time codes (static demo)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: 0.3,
                    minHeight: 3,
                    backgroundColor: color.onSurface.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(color.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0:42', style: theme.textTheme.labelSmall),
                    Text('3:15', style: theme.textTheme.labelSmall),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
