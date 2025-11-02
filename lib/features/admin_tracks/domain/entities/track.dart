class TrackArtist {
  final String artistId;
  final String? role;
  final String name;
  final String? avatarUrl;

  TrackArtist({
    required this.artistId,
    this.role,
    required this.name,
    this.avatarUrl,
  });
}

class TrackAudio {
  final String id;
  final String ext;
  final int bitrate;
  final String path;
  final DateTime? createdAt;

  TrackAudio({
    required this.id,
    required this.ext,
    required this.bitrate,
    required this.path,
    this.createdAt,
  });
}

class Track {
  final String trackId;
  final String title;
  final String? albumId;
  final String? lyricsUrl;
  final int duration;
  final int playCount;
  final bool isExplicit;
  final int likesCount;
  final int popularityScore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? videoUrl;
  final bool isPublished;
  final List<TrackArtist> artists;
  final List<TrackAudio> audios;

  Track({
    required this.trackId,
    required this.title,
    this.albumId,
    this.lyricsUrl,
    required this.duration,
    required this.playCount,
    required this.isExplicit,
    required this.likesCount,
    required this.popularityScore,
    required this.createdAt,
    required this.updatedAt,
    this.videoUrl,
    required this.isPublished,
    required this.artists,
    required this.audios,
  });
}
