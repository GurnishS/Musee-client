import 'package:flutter/material.dart';

class PageSizeDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const PageSizeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      value: value,
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
      items: const [10, 20, 50, 100]
          .map((e) => DropdownMenuItem(value: e, child: Text('Page size: $e')))
          .toList(),
    );
  }
}
