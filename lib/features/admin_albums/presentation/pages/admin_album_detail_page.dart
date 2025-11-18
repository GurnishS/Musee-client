import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:musee/features/admin_albums/domain/entities/album.dart';
import 'package:musee/features/admin_albums/domain/usecases/get_album.dart';
import 'package:musee/features/admin_albums/domain/usecases/update_album.dart';
import 'package:musee/features/admin_albums/domain/usecases/album_artists_ops.dart';
import 'package:musee/features/admin_artists/presentation/widgets/uuid_picker_dialog.dart';
import 'package:musee/features/admin_artists/domain/usecases/list_artists.dart';
import 'package:musee/init_dependencies.dart';

class AdminAlbumDetailPage extends StatefulWidget {
  final String albumId;
  const AdminAlbumDetailPage({super.key, required this.albumId});

  @override
  State<AdminAlbumDetailPage> createState() => _AdminAlbumDetailPageState();
}

class _AdminAlbumDetailPageState extends State<AdminAlbumDetailPage> {
  Album? _album;
  bool _loading = true;
  String? _error;

  // Editable
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _genresCtrl = TextEditingController();
  bool _isPublished = false;
  PlatformFile? _coverFile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _genresCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final get = serviceLocator<GetAlbum>();
    final res = await get(widget.albumId);
    res.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (a) => setState(() {
        _album = a;
        _titleCtrl.text = a.title;
        _descriptionCtrl.text = a.description ?? '';
        _genresCtrl.text = a.genres.join(', ');
        _isPublished = a.isPublished;
        _loading = false;
      }),
    );
  }

  Future<void> _pickCover() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (!mounted) return;
    if (res != null && res.files.isNotEmpty) {
      setState(() => _coverFile = res.files.first);
    }
  }

  Future<void> _save() async {
    if (_album == null) return;
    final oldCover = _album!.coverUrl;
    final genres = _genresCtrl.text.trim().isEmpty
        ? null
        : _genresCtrl.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
    final update = serviceLocator<UpdateAlbum>();
    final res = await update(
      UpdateAlbumParams(
        id: _album!.id,
        title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        genres: genres,
        isPublished: _isPublished,
        coverBytes: _coverFile?.bytes?.toList(),
        coverFilename: _coverFile?.name,
      ),
    );
    res.fold((f) => _showSnack(f.message, error: true), (updated) async {
      // Evict old and new cover
      await _evictUrl(oldCover);
      await _evictUrl(updated.coverUrl);
      setState(() {
        _album = updated;
        _coverFile = null; // reset to use network image
      });
      _showSnack('Saved');
    });
  }

  Future<void> _evictUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final provider = NetworkImage(url);
    await provider.evict();
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  Future<void> _addArtist() async {
    if (_album == null) return;
    final picked = await showDialog<UuidPickResult>(
      context: context,
      builder: (ctx) => UuidPickerDialog(
        title: 'Add artist to album',
        fetchPage: (page, limit, query) async {
          final listArtists = serviceLocator<ListArtists>();
          final res = await listArtists(
            ListArtistsParams(page: page, limit: limit, q: query),
          );
          return res.fold((_) => UuidPageResult(items: const [], total: 0), (
            tuple,
          ) {
            final items = tuple.$1
                .map(
                  (a) => UuidItem(
                    id: a.id,
                    label:
                        '${a.userName?.isNotEmpty == true
                            ? a.userName!
                            : 'Artist'} • ${a.id}',
                  ),
                )
                .toList();
            return UuidPageResult(items: items, total: tuple.$2);
          });
        },
      ),
    );
    if (picked != null) {
      final add = serviceLocator<AddAlbumArtist>();
      final r = await add(
        AddAlbumArtistParams(albumId: _album!.id, artistId: picked.id),
      );
      r.fold((f) => _showSnack(f.message, error: true), (_) => _load());
    }
  }

  Future<void> _updateRole(String artistId, String role) async {
    if (_album == null) return;
    final upd = serviceLocator<UpdateAlbumArtistRole>();
    final r = await upd(
      UpdateAlbumArtistRoleParams(
        albumId: _album!.id,
        artistId: artistId,
        role: role,
      ),
    );
    r.fold((f) => _showSnack(f.message, error: true), (_) => _load());
  }

  Future<void> _removeArtist(String artistId) async {
    if (_album == null) return;
    final rem = serviceLocator<RemoveAlbumArtist>();
    final r = await rem(
      RemoveAlbumArtistParams(albumId: _album!.id, artistId: artistId),
    );
    r.fold((f) => _showSnack(f.message, error: true), (_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Album details'),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.save))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _album == null
          ? const Center(child: Text('Not found'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      _headerSection(),
                      const SizedBox(height: 16),
                      _artistsSection(),
                      const SizedBox(height: 16),
                      _tracksSection(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _headerSection() {
    final a = _album!;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _coverFile?.bytes != null
                      ? Image.memory(
                          _coverFile!.bytes as Uint8List,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      : (a.coverUrl != null
                            ? Image.network(
                                a.coverUrl!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 120,
                                height: 120,
                                color: Colors.black12,
                                child: const Icon(Icons.album, size: 40),
                              )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleCtrl,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
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
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: _pickCover,
                            icon: const Icon(Icons.image),
                            label: const Text('Change cover'),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.save),
                            label: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _metaChip('Album ID', a.id),
                _metaChip(
                  'Created',
                  a.createdAt?.toLocal().toString().split('.').first ?? '—',
                ),
                _metaChip(
                  'Updated',
                  a.updatedAt?.toLocal().toString().split('.').first ?? '—',
                ),
                _metaChip('Tracks', a.totalTracks?.toString() ?? '—'),
                _metaChip('Duration', a.duration?.toString() ?? '—'),
                _metaChip('Likes', a.likesCount?.toString() ?? '—'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(String label, String value) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(value),
        ],
      ),
    );
  }

  Widget _artistsSection() {
    final a = _album!;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Artists',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _addArtist,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add artist'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (a.artists.isEmpty)
              const Text('No artists linked yet.')
            else
              Column(
                children: [
                  for (final link in a.artists)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundImage: link.avatarUrl != null
                            ? NetworkImage(link.avatarUrl!)
                            : null,
                        child: link.avatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(link.name ?? link.artistId ?? 'Unknown'),
                      subtitle: Text(link.artistId ?? ''),
                      trailing: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          DropdownButton<String>(
                            value: link.role ?? 'viewer',
                            items: const [
                              DropdownMenuItem(
                                value: 'owner',
                                child: Text('owner'),
                              ),
                              DropdownMenuItem(
                                value: 'editor',
                                child: Text('editor'),
                              ),
                              DropdownMenuItem(
                                value: 'viewer',
                                child: Text('viewer'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null && link.artistId != null) {
                                _updateRole(link.artistId!, v);
                              }
                            },
                          ),
                          IconButton(
                            tooltip: 'Remove',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: link.artistId != null
                                ? () => _removeArtist(link.artistId!)
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _tracksSection() {
    final a = _album!;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tracks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (a.tracks == null || a.tracks!.isEmpty)
              const Text('No tracks')
            else
              Column(
                children: [
                  for (final t in a.tracks!)
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: t.coverUrl != null
                            ? Image.network(
                                t.coverUrl!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 44,
                                height: 44,
                                color: Colors.black12,
                                child: const Icon(Icons.music_note),
                              ),
                      ),
                      title: Text(t.title),
                      subtitle: Text(
                        '${t.duration}s · ${t.isExplicit ? 'Explicit' : 'Clean'}',
                      ),
                      trailing: t.isPublished != null
                          ? Icon(
                              t.isPublished!
                                  ? Icons.check_circle
                                  : Icons.unpublished,
                              color: t.isPublished!
                                  ? Colors.green
                                  : Colors.orange,
                            )
                          : null,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
