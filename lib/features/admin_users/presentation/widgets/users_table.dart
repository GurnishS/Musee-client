import 'package:flutter/material.dart';
import 'package:musee/core/common/entities/user.dart';

class UsersTable extends StatelessWidget {
  final List<User> users;
  final void Function(User user) onEdit;
  final void Function(User user) onDelete;
  const UsersTable({
    super.key,
    required this.users,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 800),
        child: SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Avatar')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Subscription')),
              DataColumn(label: Text('Last login')),
              DataColumn(label: Text('Actions')),
            ],
            rows: users.map((u) {
              return DataRow(
                cells: [
                  DataCell(
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: u.avatarUrl.isNotEmpty
                          ? NetworkImage(u.avatarUrl)
                          : null,
                      child: u.avatarUrl.isEmpty
                          ? Text(
                              u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                            )
                          : null,
                    ),
                  ),
                  DataCell(Text(u.name)),
                  DataCell(Text(u.email ?? '—')),
                  DataCell(Text(u.userType.value)),
                  DataCell(Text(u.subscriptionType.value)),
                  DataCell(
                    Text(
                      u.lastLoginAt?.toLocal().toString().split('.').first ??
                          '—',
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit),
                          onPressed: () => onEdit(u),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => onDelete(u),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
