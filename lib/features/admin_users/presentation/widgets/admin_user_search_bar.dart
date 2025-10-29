import 'package:flutter/material.dart';

class AdminUserSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String value) onSubmitted;
  const AdminUserSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search by name or email',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onSubmitted: (value) => onSubmitted(value.trim()),
    );
  }
}
