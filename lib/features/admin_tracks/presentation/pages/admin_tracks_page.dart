import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/admin_tracks_bloc.dart';
import '../../domain/entities/track.dart';

class AdminTracksPage extends StatefulWidget {
  const AdminTracksPage({super.key});

  @override
  State<AdminTracksPage> createState() => _AdminTracksPageState();
}

class _AdminTracksPageState extends State<AdminTracksPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  int _limit = 20;
  @override
  void initState() {
    super.initState();
    context.read<AdminTracksBloc>().add(LoadTracks(page: 0, limit: _limit));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Admin • Tracks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateDialog(context),
        icon: const Icon(Icons.library_music_outlined),
        label: const Text('New Track'),
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
                    onSubmitted: (v) => context.read<AdminTracksBloc>().add(
                      LoadTracks(
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
                    context.read<AdminTracksBloc>().add(
                      LoadTracks(
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
              child: BlocBuilder<AdminTracksBloc, AdminTracksState>(
                builder: (context, state) {
                  if (state is AdminTracksLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is AdminTracksFailure) {
                    return Center(
                      child: Text(
                        state.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    );
                  }
                  if (state is AdminTracksPageLoaded) {
                    final List<Track> items = state.items;
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
                              if (items.isEmpty) {
                                return const Center(
                                  child: Text('No tracks found'),
                                );
                              }
                              if (isMobile) {
                                return ListView.separated(
                                  itemCount: items.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final t = items[index];
                                    final artists = t.artists.isNotEmpty
                                        ? t.artists
                                              .map((a) => a.name)
                                              .join(', ')
                                        : '—';
                                    return Card(
                                      child: ListTile(
                                        leading: const Icon(Icons.music_note),
                                        title: Text(t.title),
                                        subtitle: Text(artists),
                                        trailing: Wrap(
                                          spacing: 4,
                                          children: [
                                            if (t.isPublished)
                                              const Icon(
                                                Icons.public,
                                                size: 18,
                                                color: Colors.green,
                                              ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.group_outlined,
                                              ),
                                              tooltip: 'Manage artists',
                                              onPressed: () =>
                                                  _openArtistsDialog(t),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () =>
                                                  _openEditDialog(t),
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
                                                      'Delete track?',
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to delete "${t.title}"? This cannot be undone.',
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
                                                      .read<AdminTracksBloc>()
                                                      .add(
                                                        DeleteTrackEvent(
                                                          t.trackId,
                                                        ),
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

                              // Wide: DataTable
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Title')),
                                    DataColumn(label: Text('Artists')),
                                    DataColumn(label: Text('Published')),
                                    DataColumn(label: Text('Created')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: items.map((t) {
                                    final artists = t.artists.isNotEmpty
                                        ? t.artists
                                              .map((a) => a.name)
                                              .join(', ')
                                        : '—';
                                    return DataRow(
                                      cells: [
                                        DataCell(Text(t.title)),
                                        DataCell(
                                          SizedBox(
                                            width: 280,
                                            child: Text(
                                              artists,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Icon(
                                            t.isPublished
                                                ? Icons.check
                                                : Icons.close,
                                            size: 18,
                                            color: t.isPublished
                                                ? Colors.green
                                                : Colors.redAccent,
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            t.createdAt
                                                .toLocal()
                                                .toString()
                                                .split('.')
                                                .first,
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.group_outlined,
                                                ),
                                                tooltip: 'Manage artists',
                                                onPressed: () =>
                                                    _openArtistsDialog(t),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                onPressed: () =>
                                                    _openEditDialog(t),
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
                                                            'Delete track?',
                                                          ),
                                                          content: Text(
                                                            'Are you sure you want to delete "${t.title}"? This cannot be undone.',
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
                                                        .read<AdminTracksBloc>()
                                                        .add(
                                                          DeleteTrackEvent(
                                                            t.trackId,
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
                                            context.read<AdminTracksBloc>().add(
                                              LoadTracks(
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
                                            context.read<AdminTracksBloc>().add(
                                              LoadTracks(
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

  Future<void> _openCreateDialog(BuildContext context) async {
    String title = '';
    String albumId = '';
    String durationStr = '';
    String lyricsUrl = '';
    String artistIdsCsv = '';
    String artistRole = 'viewer';
    bool isExplicit = false;
    bool isPublished = false;
    PlatformFile? audioFile;
    PlatformFile? videoFile;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            title: const Text('Create Track'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title *'),
                    onChanged: (v) => title = v,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Album ID *'),
                    onChanged: (v) => albumId = v,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Duration (seconds) *',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => durationStr = v,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Lyrics URL'),
                    onChanged: (v) => lyricsUrl = v,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Additional artist IDs (comma-separated)',
                    ),
                    onChanged: (v) => artistIdsCsv = v,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: artistRole,
                    decoration: const InputDecoration(
                      labelText: 'Role for additional artists',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'viewer', child: Text('viewer')),
                      DropdownMenuItem(value: 'editor', child: Text('editor')),
                      DropdownMenuItem(value: 'owner', child: Text('owner')),
                    ],
                    onChanged: (v) => artistRole = v ?? artistRole,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: isExplicit,
                          onChanged: (v) =>
                              setState(() => isExplicit = v ?? false),
                          title: const Text('Explicit'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: isPublished,
                          onChanged: (v) =>
                              setState(() => isPublished = v ?? false),
                          title: const Text('Published'),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  _FilePickerTile(
                    label: 'Audio *',
                    pickedName: audioFile?.name,
                    onPick: () async {
                      final res = await FilePicker.platform.pickFiles(
                        withData: true,
                        type: FileType.custom,
                        allowedExtensions: ['mp3', 'ogg', 'wav', 'm4a'],
                      );
                      if (res != null && res.files.isNotEmpty) {
                        setState(() => audioFile = res.files.first);
                      }
                    },
                    onClear: () => setState(() => audioFile = null),
                  ),
                  // Cover image removed in schema; album provides cover
                  _FilePickerTile(
                    label: 'Video (optional)',
                    pickedName: videoFile?.name,
                    onPick: () async {
                      final res = await FilePicker.platform.pickFiles(
                        withData: true,
                        type: FileType.video,
                      );
                      if (res != null && res.files.isNotEmpty) {
                        setState(() => videoFile = res.files.first);
                      }
                    },
                    onClear: () => setState(() => videoFile = null),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Create'),
                onPressed: () {
                  final parsedDuration = int.tryParse(durationStr.trim());
                  if (title.trim().isEmpty ||
                      albumId.trim().isEmpty ||
                      parsedDuration == null ||
                      audioFile?.bytes == null ||
                      (audioFile?.name.isEmpty ?? true)) {
                    // simple validation
                    return;
                  }
                  context.read<AdminTracksBloc>().add(
                    CreateTrackEvent(
                      title: title.trim(),
                      albumId: albumId.trim(),
                      duration: parsedDuration,
                      lyricsUrl: lyricsUrl.trim().isEmpty
                          ? null
                          : lyricsUrl.trim(),
                      isExplicit: isExplicit,
                      isPublished: isPublished,
                      audioBytes: audioFile!.bytes!,
                      audioFilename: audioFile!.name,
                      videoBytes: videoFile?.bytes,
                      videoFilename: videoFile?.name,
                      artists: artistIdsCsv
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .map((id) => {'artist_id': id, 'role': artistRole})
                          .toList(),
                    ),
                  );
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditDialog(Track t) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(child: _EditTrackDialog(track: t)),
    );
  }

  void _openArtistsDialog(Track t) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(child: _ManageTrackArtistsDialog(track: t)),
    );
  }
}

class _EditTrackDialog extends StatefulWidget {
  final Track track;
  const _EditTrackDialog({required this.track});

  @override
  State<_EditTrackDialog> createState() => _EditTrackDialogState();
}

class _EditTrackDialogState extends State<_EditTrackDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _albumCtrl;
  late TextEditingController _durationCtrl;
  late TextEditingController _lyricsCtrl;
  bool _isExplicit = false;
  bool _isPublished = false;
  PlatformFile? _audioFile;
  PlatformFile? _videoFile;
  String _artistIdsCsv = '';
  String _artistRole = 'viewer';

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.track.title);
    _albumCtrl = TextEditingController(text: widget.track.albumId ?? '');
    _durationCtrl = TextEditingController(
      text: widget.track.duration.toString(),
    );
    _lyricsCtrl = TextEditingController(text: widget.track.lyricsUrl ?? '');
    _isExplicit = widget.track.isExplicit;
    _isPublished = widget.track.isPublished;
    _artistIdsCsv = '';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _albumCtrl.dispose();
    _durationCtrl.dispose();
    _lyricsCtrl.dispose();
    super.dispose();
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
                  'Edit track',
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
                  controller: _albumCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Album ID (uuid)',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (seconds)',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _lyricsCtrl,
                  decoration: const InputDecoration(labelText: 'Lyrics URL'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _isExplicit,
                        onChanged: (v) =>
                            setState(() => _isExplicit = v ?? false),
                        title: const Text('Explicit'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _isPublished,
                        onChanged: (v) =>
                            setState(() => _isPublished = v ?? false),
                        title: const Text('Published'),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                TextFormField(
                  initialValue: _artistIdsCsv,
                  decoration: const InputDecoration(
                    labelText: 'Additional artist IDs (comma-separated)',
                  ),
                  onChanged: (v) => _artistIdsCsv = v,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _artistRole,
                  decoration: const InputDecoration(
                    labelText: 'Role for additional artists',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'viewer', child: Text('viewer')),
                    DropdownMenuItem(value: 'editor', child: Text('editor')),
                    DropdownMenuItem(value: 'owner', child: Text('owner')),
                  ],
                  onChanged: (v) =>
                      setState(() => _artistRole = v ?? _artistRole),
                ),
                const Divider(),
                _FilePickerTile(
                  label: 'Replace audio (optional)',
                  pickedName: _audioFile?.name,
                  onPick: () async {
                    final res = await FilePicker.platform.pickFiles(
                      withData: true,
                      type: FileType.custom,
                      allowedExtensions: ['mp3', 'ogg', 'wav', 'm4a'],
                    );
                    if (res != null && res.files.isNotEmpty) {
                      setState(() => _audioFile = res.files.first);
                    }
                  },
                  onClear: () => setState(() => _audioFile = null),
                ),
                _FilePickerTile(
                  label: 'Replace video (optional)',
                  pickedName: _videoFile?.name,
                  onPick: () async {
                    final res = await FilePicker.platform.pickFiles(
                      withData: true,
                      type: FileType.video,
                    );
                    if (res != null && res.files.isNotEmpty) {
                      setState(() => _videoFile = res.files.first);
                    }
                  },
                  onClear: () => setState(() => _videoFile = null),
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
                        final duration = int.tryParse(
                          _durationCtrl.text.trim(),
                        );
                        context.read<AdminTracksBloc>().add(
                          UpdateTrackEvent(
                            id: widget.track.trackId,
                            title: _titleCtrl.text.trim(),
                            albumId: _albumCtrl.text.trim(),
                            duration: duration,
                            lyricsUrl: _lyricsCtrl.text.trim().isEmpty
                                ? null
                                : _lyricsCtrl.text.trim(),
                            isExplicit: _isExplicit,
                            isPublished: _isPublished,
                            audioBytes: _audioFile?.bytes,
                            audioFilename: _audioFile?.name,
                            videoBytes: _videoFile?.bytes,
                            videoFilename: _videoFile?.name,
                            artists: _artistIdsCsv
                                .split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .map(
                                  (id) => {
                                    'artist_id': id,
                                    'role': _artistRole,
                                  },
                                )
                                .toList(),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
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

class _FilePickerTile extends StatelessWidget {
  final String label;
  final String? pickedName;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _FilePickerTile({
    required this.label,
    required this.pickedName,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (pickedName != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  pickedName!,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          if (pickedName != null)
            IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.close),
              onPressed: onClear,
            ),
          FilledButton.tonal(onPressed: onPick, child: const Text('Choose')),
        ],
      ),
    );
  }
}

class _ManageTrackArtistsDialog extends StatefulWidget {
  final Track track;
  const _ManageTrackArtistsDialog({required this.track});

  @override
  State<_ManageTrackArtistsDialog> createState() =>
      _ManageTrackArtistsDialogState();
}

class _ManageTrackArtistsDialogState extends State<_ManageTrackArtistsDialog> {
  late List<TrackArtist> _artists;
  final TextEditingController _artistIdCtrl = TextEditingController();
  String _newRole = 'viewer';

  @override
  void initState() {
    super.initState();
    _artists = List.of(widget.track.artists);
  }

  @override
  void dispose() {
    _artistIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage artists',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            // Existing artists list
            if (_artists.isEmpty) const Text('No linked artists'),
            if (_artists.isNotEmpty)
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _artists.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (ctx, i) {
                    final a = _artists[i];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.name.isNotEmpty ? a.name : a.artistId,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                a.artistId,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: (a.role ?? 'viewer'),
                          items: const [
                            DropdownMenuItem(
                              value: 'viewer',
                              child: Text('viewer'),
                            ),
                            DropdownMenuItem(
                              value: 'editor',
                              child: Text('editor'),
                            ),
                            DropdownMenuItem(
                              value: 'owner',
                              child: Text('owner'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            // Optimistic update
                            setState(() {
                              _artists[i] = TrackArtist(
                                artistId: a.artistId,
                                role: v,
                                name: a.name,
                                avatarUrl: a.avatarUrl,
                              );
                            });
                            context.read<AdminTracksBloc>().add(
                              UpdateTrackArtistRoleEvent(
                                trackId: widget.track.trackId,
                                artistId: a.artistId,
                                role: v,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() => _artists.removeAt(i));
                            context.read<AdminTracksBloc>().add(
                              UnlinkArtistFromTrackEvent(
                                trackId: widget.track.trackId,
                                artistId: a.artistId,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text('Add artist'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _artistIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Artist ID (uuid)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _newRole,
                  items: const [
                    DropdownMenuItem(value: 'viewer', child: Text('viewer')),
                    DropdownMenuItem(value: 'editor', child: Text('editor')),
                    DropdownMenuItem(value: 'owner', child: Text('owner')),
                  ],
                  onChanged: (v) => setState(() => _newRole = v ?? _newRole),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.link),
                  label: const Text('Link'),
                  onPressed: () {
                    final id = _artistIdCtrl.text.trim();
                    if (id.isEmpty) return;
                    // Optimistic add
                    setState(() {
                      _artists.add(
                        TrackArtist(artistId: id, role: _newRole, name: id),
                      );
                      _artistIdCtrl.clear();
                    });
                    context.read<AdminTracksBloc>().add(
                      LinkArtistToTrackEvent(
                        trackId: widget.track.trackId,
                        artistId: id,
                        role: _newRole,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
