import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musee/features/admin_albums/domain/entities/album.dart';
import 'package:musee/features/admin_albums/presentation/bloc/admin_albums_bloc.dart';

class AdminAlbumsPage extends StatefulWidget {
  const AdminAlbumsPage({super.key});

  @override
  State<AdminAlbumsPage> createState() => _AdminAlbumsPageState();
}

class _AdminAlbumsPageState extends State<AdminAlbumsPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _limit = 20;

  @override
  void initState() {
    super.initState();
    context.read<AdminAlbumsBloc>().add(LoadAlbums(page: 0, limit: _limit));
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
        child: BlocProvider.value(
          value: context.read<AdminAlbumsBloc>(),
          child: const _CreateAlbumDialog(),
        ),
      ),
    );
  }

  void _openEditDialog(Album a) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: BlocProvider.value(
          value: context.read<AdminAlbumsBloc>(),
          child: _EditAlbumDialog(album: a),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin • Albums'),
        actions: [
          IconButton(
            onPressed: _openCreateDialog,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            tooltip: 'Create album',
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
                      hintText: 'Search by title',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (v) => context.read<AdminAlbumsBloc>().add(
                      LoadAlbums(
                        page: 0,
                        limit: _limit,
                        search: v.trim().isEmpty ? null : v.trim(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _limit,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _limit = v);
                    context.read<AdminAlbumsBloc>().add(
                      LoadAlbums(
                        page: 0,
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
              child: BlocBuilder<AdminAlbumsBloc, AdminAlbumsState>(
                builder: (context, state) {
                  if (state is AdminAlbumsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is AdminAlbumsFailure) {
                    return Center(
                      child: Text(
                        state.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    );
                  }
                  if (state is AdminAlbumsPageLoaded) {
                    final albums = state.items;
                    final totalPages = (state.total / state.limit).ceil().clamp(
                      1,
                      999999,
                    );
                    return Column(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final isMobile = c.maxWidth < 700;
                              if (isMobile) {
                                return ListView.separated(
                                  itemCount: albums.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, i) {
                                    final a = albums[i];
                                    return Card(
                                      child: ListTile(
                                        leading: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: a.coverUrl != null
                                              ? Image.network(
                                                  a.coverUrl!,
                                                  width: 44,
                                                  height: 44,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  width: 44,
                                                  height: 44,
                                                  color: Colors.black12,
                                                  child: const Icon(
                                                    Icons.album,
                                                  ),
                                                ),
                                        ),
                                        title: Text(a.title),
                                        subtitle: Text(a.description ?? ''),
                                        trailing: Wrap(
                                          spacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            if (a.isPublished)
                                              const Icon(
                                                Icons.public,
                                                size: 18,
                                                color: Colors.green,
                                              ),
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () =>
                                                  _openEditDialog(a),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                              ),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    title: const Text(
                                                      'Delete album?',
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to delete "${a.title}"?',
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
                                                      .read<AdminAlbumsBloc>()
                                                      .add(
                                                        DeleteAlbumEvent(a.id),
                                                      );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }

                              // wide: DataTable
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Cover')),
                                    DataColumn(label: Text('Title')),
                                    DataColumn(label: Text('Published')),
                                    DataColumn(label: Text('Created')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: albums.map((a) {
                                    return DataRow(
                                      cells: [
                                        DataCell(
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: a.coverUrl != null
                                                ? Image.network(
                                                    a.coverUrl!,
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: 40,
                                                    height: 40,
                                                    color: Colors.black12,
                                                    child: const Icon(
                                                      Icons.album,
                                                      size: 20,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        DataCell(Text(a.title)),
                                        DataCell(
                                          Icon(
                                            a.isPublished
                                                ? Icons.check
                                                : Icons.close,
                                            size: 18,
                                            color: a.isPublished
                                                ? Colors.green
                                                : Colors.redAccent,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            a.createdAt
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
                                                icon: const Icon(Icons.edit),
                                                onPressed: () =>
                                                    _openEditDialog(a),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                onPressed: () async {
                                                  final confirm =
                                                      await showDialog<bool>(
                                                        context: context,
                                                        builder: (ctx) => AlertDialog(
                                                          title: const Text(
                                                            'Delete album?',
                                                          ),
                                                          content: Text(
                                                            'Are you sure you want to delete "${a.title}"?',
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
                                                        .read<AdminAlbumsBloc>()
                                                        .add(
                                                          DeleteAlbumEvent(
                                                            a.id,
                                                          ),
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
                              );
                            },
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
                                  onPressed: state.page > 0
                                      ? () =>
                                            context.read<AdminAlbumsBloc>().add(
                                              LoadAlbums(
                                                page: state.page - 1,
                                                limit: state.limit,
                                                search: state.search,
                                              ),
                                            )
                                      : null,
                                  icon: const Icon(Icons.chevron_left),
                                ),
                                Text('Page ${state.page + 1} of $totalPages'),
                                IconButton(
                                  onPressed: state.page < totalPages - 1
                                      ? () =>
                                            context.read<AdminAlbumsBloc>().add(
                                              LoadAlbums(
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

class _CreateAlbumDialog extends StatefulWidget {
  const _CreateAlbumDialog();

  @override
  State<_CreateAlbumDialog> createState() => _CreateAlbumDialogState();
}

class _CreateAlbumDialogState extends State<_CreateAlbumDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _artistIdCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _genresCtrl = TextEditingController();
  bool _isPublished = false;
  List<int>? _coverBytes;
  String? _coverFilename;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistIdCtrl.dispose();
    _descriptionCtrl.dispose();
    _genresCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (res != null && res.files.isNotEmpty && res.files.first.bytes != null) {
      setState(() {
        _coverBytes = res.files.first.bytes;
        _coverFilename = res.files.first.name;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final genres = _genresCtrl.text.trim().isEmpty
        ? null
        : _genresCtrl.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
    context.read<AdminAlbumsBloc>().add(
      CreateAlbumEvent(
        title: _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        genres: genres,
        isPublished: _isPublished,
        artistId: _artistIdCtrl.text.trim(),
        coverBytes: _coverBytes,
        coverFilename: _coverFilename,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create album',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _artistIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Owner artist_id (uuid)',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _genresCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Genres (comma-separated)',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _isPublished,
                      onChanged: (v) =>
                          setState(() => _isPublished = v ?? false),
                    ),
                    const Text('Published'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                        image: _coverBytes != null
                            ? DecorationImage(
                                image: MemoryImage(
                                  Uint8List.fromList(_coverBytes!),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _coverBytes == null
                          ? const Icon(Icons.image)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _coverFilename ?? 'No cover selected',
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _pickCover,
                                icon: const Icon(Icons.image),
                                label: const Text('Select cover'),
                              ),
                              if (_coverBytes != null)
                                TextButton.icon(
                                  onPressed: () => setState(() {
                                    _coverBytes = null;
                                    _coverFilename = null;
                                  }),
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
                      onPressed: _submit,
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EditAlbumDialog extends StatefulWidget {
  final Album album;
  const _EditAlbumDialog({required this.album});

  @override
  State<_EditAlbumDialog> createState() => _EditAlbumDialogState();
}

class _EditAlbumDialogState extends State<_EditAlbumDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _genresCtrl;
  bool _isPublished = false;
  List<int>? _coverBytes;
  String? _coverFilename;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.album.title);
    _descriptionCtrl = TextEditingController(
      text: widget.album.description ?? '',
    );
    _genresCtrl = TextEditingController(text: widget.album.genres.join(', '));
    _isPublished = widget.album.isPublished;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _genresCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (res != null && res.files.isNotEmpty && res.files.first.bytes != null) {
      setState(() {
        _coverBytes = res.files.first.bytes;
        _coverFilename = res.files.first.name;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final genres = _genresCtrl.text.trim().isEmpty
        ? null
        : _genresCtrl.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
    context.read<AdminAlbumsBloc>().add(
      UpdateAlbumEvent(
        id: widget.album.id,
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        genres: genres,
        isPublished: _isPublished,
        coverBytes: _coverBytes,
        coverFilename: _coverFilename,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit album',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _genresCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Genres (comma-separated)',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _isPublished,
                      onChanged: (v) =>
                          setState(() => _isPublished = v ?? false),
                    ),
                    const Text('Published'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                        image: _coverBytes != null
                            ? DecorationImage(
                                image: MemoryImage(
                                  Uint8List.fromList(_coverBytes!),
                                ),
                                fit: BoxFit.cover,
                              )
                            : (widget.album.coverUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        widget.album.coverUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                      ),
                      child:
                          (_coverBytes == null && widget.album.coverUrl == null)
                          ? const Icon(Icons.image)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _coverFilename ?? 'No cover selected',
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _pickCover,
                                icon: const Icon(Icons.image),
                                label: const Text('Select cover'),
                              ),
                              if (_coverBytes != null)
                                TextButton.icon(
                                  onPressed: () => setState(() {
                                    _coverBytes = null;
                                    _coverFilename = null;
                                  }),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(onPressed: _submit, child: const Text('Save')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
