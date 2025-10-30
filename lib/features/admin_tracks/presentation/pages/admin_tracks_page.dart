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
  @override
  void initState() {
    super.initState();
    context.read<AdminTracksBloc>().add(LoadTracks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Tracks')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateDialog(context),
        icon: const Icon(Icons.library_music_outlined),
        label: const Text('New Track'),
      ),
      body: BlocBuilder<AdminTracksBloc, AdminTracksState>(
        builder: (context, state) {
          if (state is AdminTracksLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminTracksFailure) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is AdminTracksPageLoaded) {
            final List<Track> items = state.items;
            if (items.isEmpty) {
              return const Center(child: Text('No tracks found'));
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = items[index];
                final title = t.title;
                final subtitle = t.artists.isNotEmpty
                    ? t.artists.map((a) => a.name).join(', ')
                    : '';
                return ListTile(
                  title: Text(title.toString()),
                  subtitle: Text(subtitle.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      // confirm delete
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete track?'),
                          content: const Text(
                            'This will permanently delete the track.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                final id = t.trackId;
                                context.read<AdminTracksBloc>().add(
                                  DeleteTrackEvent(id),
                                );
                              },
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _openCreateDialog(BuildContext context) async {
    String title = '';
    String albumId = '';
    String durationStr = '';
    String lyricsUrl = '';
    bool isExplicit = false;
    bool isPublished = false;
    PlatformFile? audioFile;
    PlatformFile? coverFile;
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
                    label: 'Audio (optional)',
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
                  _FilePickerTile(
                    label: 'Cover Image (optional)',
                    pickedName: coverFile?.name,
                    onPick: () async {
                      final res = await FilePicker.platform.pickFiles(
                        withData: true,
                        type: FileType.image,
                      );
                      if (res != null && res.files.isNotEmpty) {
                        setState(() => coverFile = res.files.first);
                      }
                    },
                    onClear: () => setState(() => coverFile = null),
                  ),
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
                      parsedDuration == null) {
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
                      audioBytes: audioFile?.bytes,
                      audioFilename: audioFile?.name,
                      coverBytes: coverFile?.bytes,
                      coverFilename: coverFile?.name,
                      videoBytes: videoFile?.bytes,
                      videoFilename: videoFile?.name,
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
