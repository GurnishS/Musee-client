import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musee/core/common/entities/user.dart';
import 'package:musee/features/admin_users/presentation/bloc/admin_users_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _limit = 20;

  @override
  void initState() {
    super.initState();
    context.read<AdminUsersBloc>().add(LoadUsers(page: 1, limit: _limit));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: _UserFormDialog(
          onSubmit:
              (
                name,
                email,
                subType,
                userType,
                planId,
                avatarBytes,
                avatarFilename,
              ) {
                context.read<AdminUsersBloc>().add(
                  CreateUserEvent(
                    name: name,
                    email: email,
                    subscriptionType: subType,
                    userType: userType,
                    planId: planId,
                    avatarBytes: avatarBytes?.toList(),
                    avatarFilename: avatarFilename,
                  ),
                );
              },
        ),
      ),
    );
  }

  void _openEditDialog(User user) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: _UserFormDialog(
          user: user,
          onSubmit:
              (
                name,
                email,
                subType,
                userType,
                planId,
                avatarBytes,
                avatarFilename,
              ) {
                context.read<AdminUsersBloc>().add(
                  UpdateUserEvent(
                    id: user.id,
                    name: name,
                    email: email,
                    subscriptionType: subType,
                    userType: userType,
                    planId: planId,
                    avatarBytes: avatarBytes?.toList(),
                    avatarFilename: avatarFilename,
                  ),
                );
              },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin • Users'),
        actions: [
          IconButton(
            onPressed: _openCreateDialog,
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Create user',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by name or email',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (value) {
                      context.read<AdminUsersBloc>().add(
                        LoadUsers(
                          page: 1,
                          limit: _limit,
                          search: value.trim().isEmpty ? null : value.trim(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _limit,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _limit = v);
                    context.read<AdminUsersBloc>().add(
                      LoadUsers(
                        page: 1,
                        limit: v,
                        search: _searchCtrl.text.trim().isEmpty
                            ? null
                            : _searchCtrl.text.trim(),
                      ),
                    );
                  },
                  items: const [10, 20, 50, 100]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text('Page size: $e'),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
                builder: (context, state) {
                  if (state is AdminUsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is AdminUsersFailure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            state.message,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => context.read<AdminUsersBloc>().add(
                              LoadUsers(
                                page: 1,
                                limit: _limit,
                                search: _searchCtrl.text.trim().isEmpty
                                    ? null
                                    : _searchCtrl.text.trim(),
                              ),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is AdminUsersPageLoaded) {
                    final users = state.items;
                    final totalPages = (state.total / state.limit).ceil().clamp(
                      1,
                      999999,
                    );
                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
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
                                            backgroundImage:
                                                u.avatarUrl.isNotEmpty
                                                ? NetworkImage(u.avatarUrl)
                                                : null,
                                            child: u.avatarUrl.isEmpty
                                                ? Text(
                                                    u.name.isNotEmpty
                                                        ? u.name[0]
                                                              .toUpperCase()
                                                        : '?',
                                                  )
                                                : null,
                                          ),
                                        ),
                                        DataCell(Text(u.name)),
                                        DataCell(Text(u.email ?? '—')),
                                        DataCell(Text(u.userType.value)),
                                        DataCell(
                                          Text(u.subscriptionType.value),
                                        ),
                                        DataCell(
                                          Text(
                                            u.lastLoginAt
                                                    ?.toLocal()
                                                    .toString()
                                                    .split('.')
                                                    .first ??
                                                '—',
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                tooltip: 'Edit',
                                                icon: const Icon(Icons.edit),
                                                onPressed: () =>
                                                    _openEditDialog(u),
                                              ),
                                              IconButton(
                                                tooltip: 'Delete',
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                onPressed: () async {
                                                  final confirm =
                                                      await showDialog<bool>(
                                                        context: context,
                                                        builder: (ctx) => AlertDialog(
                                                          title: const Text(
                                                            'Delete user?',
                                                          ),
                                                          content: Text(
                                                            'Are you sure you want to delete ${u.name}? This cannot be undone.',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                    false,
                                                                  ),
                                                              child: const Text(
                                                                'Cancel',
                                                              ),
                                                            ),
                                                            FilledButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    ctx,
                                                                    true,
                                                                  ),
                                                              child: const Text(
                                                                'Delete',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                  if (confirm == true) {
                                                    context
                                                        .read<AdminUsersBloc>()
                                                        .add(
                                                          DeleteUserEvent(u.id),
                                                        );
                                                  }
                                                },
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
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total: ${state.total}'),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: state.page > 1
                                      ? () =>
                                            context.read<AdminUsersBloc>().add(
                                              LoadUsers(
                                                page: state.page - 1,
                                                limit: state.limit,
                                                search: state.search,
                                              ),
                                            )
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                ),
                                Text('Page ${state.page} of $totalPages'),
                                IconButton(
                                  onPressed: state.page < totalPages
                                      ? () =>
                                            context.read<AdminUsersBloc>().add(
                                              LoadUsers(
                                                page: state.page + 1,
                                                limit: state.limit,
                                                search: state.search,
                                              ),
                                            )
                                      : null,
                                  icon: const Icon(Icons.chevron_right),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final User? user;
  final void Function(
    String name,
    String email,
    SubscriptionType subType,
    UserType userType,
    String? planId,
    Uint8List? avatarBytes,
    String? avatarFilename,
  )
  onSubmit;

  const _UserFormDialog({this.user, required this.onSubmit});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _planCtrl;
  SubscriptionType _subscriptionType = SubscriptionType.free;
  UserType _userType = UserType.listener;
  Uint8List? _avatarBytes;
  String? _avatarFilename;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _planCtrl = TextEditingController(text: widget.user?.planId ?? '');
    _subscriptionType = widget.user?.subscriptionType ?? SubscriptionType.free;
    _userType = widget.user?.userType ?? UserType.listener;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _planCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Edit user' : 'Create user',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              // Avatar preview and picker
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: _avatarBytes != null
                        ? MemoryImage(_avatarBytes!)
                        : (widget.user != null &&
                              widget.user!.avatarUrl.isNotEmpty)
                        ? NetworkImage(widget.user!.avatarUrl) as ImageProvider
                        : null,
                    child:
                        (_avatarBytes == null &&
                            (widget.user?.avatarUrl.isEmpty ?? true))
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _avatarFilename ?? 'No image selected',
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                final result = await FilePicker.platform
                                    .pickFiles(
                                      type: FileType.image,
                                      allowMultiple: false,
                                      withData: true,
                                    );
                                if (result != null && result.files.isNotEmpty) {
                                  final f = result.files.first;
                                  if (f.bytes != null) {
                                    setState(() {
                                      _avatarBytes = f.bytes;
                                      _avatarFilename = f.name;
                                    });
                                  }
                                }
                              },
                              icon: const Icon(Icons.image),
                              label: const Text('Select image'),
                            ),
                            if (_avatarBytes != null)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _avatarBytes = null;
                                    _avatarFilename = null;
                                  });
                                },
                                icon: const Icon(Icons.clear),
                                label: const Text('Clear'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<SubscriptionType>(
                value: _subscriptionType,
                items: SubscriptionType.values
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _subscriptionType = v ?? _subscriptionType),
                decoration: const InputDecoration(
                  labelText: 'Subscription Type',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserType>(
                value: _userType,
                items: UserType.values
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _userType = v ?? _userType),
                decoration: const InputDecoration(labelText: 'User Type'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _planCtrl,
                decoration: const InputDecoration(
                  labelText: 'Plan ID (optional)',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() != true) return;
                      widget.onSubmit(
                        _nameCtrl.text.trim(),
                        _emailCtrl.text.trim(),
                        _subscriptionType,
                        _userType,
                        _planCtrl.text.trim().isEmpty
                            ? null
                            : _planCtrl.text.trim(),
                        _avatarBytes,
                        _avatarFilename,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(isEdit ? 'Save' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
