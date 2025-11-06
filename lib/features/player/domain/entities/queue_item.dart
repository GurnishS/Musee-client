import 'package:equatable/equatable.dart';

class QueueItem extends Equatable {
  final String trackId;
  final String title;
  final String artist; // comma-separated artists
  final String? album;
  final String? imageUrl;
  final int? durationSeconds;

  const QueueItem({
    required this.trackId,
    required this.title,
    required this.artist,
    this.album,
    this.imageUrl,
    this.durationSeconds,
  });

  @override
  List<Object?> get props => [trackId, title, artist, album, imageUrl, durationSeconds];

  QueueItem copyWith({
    String? trackId,
    String? title,
    String? artist,
    String? album,
    String? imageUrl,
    int? durationSeconds,
  }) {
    return QueueItem(
      trackId: trackId ?? this.trackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      imageUrl: imageUrl ?? this.imageUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  factory QueueItem.fromExpandedJson(Map<String, dynamic> json) {
    final artists = (json['artists'] as List?)?.map((a) => (a['name'] ?? '').toString()).where((s) => s.isNotEmpty).join(', ') ?? '';
    final hls = (json['hls'] as Map?)?.cast<String, dynamic>();
    final imageUrl = (json['image_url'] ?? json['cover_url'])?.toString();
    return QueueItem(
      trackId: (json['track_id'] ?? json['id']).toString(),
      title: (json['title'] ?? '').toString(),
      artist: artists,
      album: (json['album']?['title'] ?? json['album_title'])?.toString(),
      imageUrl: imageUrl,
      durationSeconds: (json['duration'] as num?)?.toInt(),
    );
  }
}

