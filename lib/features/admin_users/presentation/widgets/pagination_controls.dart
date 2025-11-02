import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  const PaginationControls({
    super.key,
    required this.page,
    required this.totalPages,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final displayedPage = totalPages == 0
        ? 0
        : page + 1; // convert from 0-based for display
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Page $displayedPage of $totalPages'),
        Row(
          children: [
            IconButton(
              onPressed: page > 0 ? onPrev : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: page < (totalPages - 1) ? onNext : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }
}
