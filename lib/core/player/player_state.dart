import 'package:equatable/equatable.dart';

class PlayerTrack extends Equatable {
  final String url;
  final String title;
  final String artist;
  final String? album;
  final String? imageUrl;
  final Map<String, String>? headers;

  const PlayerTrack({
    required this.url,
    required this.title,
    required this.artist,
    this.album,
    this.imageUrl,
    this.headers,
  });

  @override
  List<Object?> get props => [url, title, artist, album, imageUrl, headers];
}

class PlayerViewState extends Equatable {
  final PlayerTrack? track;
  final bool playing;
  final bool buffering;
  final Duration position;
  final Duration duration;
  final double volume;

  const PlayerViewState({
    this.track,
    this.playing = false,
    this.buffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
  });

  PlayerViewState copyWith({
    PlayerTrack? track,
    bool? playing,
    bool? buffering,
    Duration? position,
    Duration? duration,
    double? volume,
  }) {
    return PlayerViewState(
      track: track ?? this.track,
      playing: playing ?? this.playing,
      buffering: buffering ?? this.buffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
    );
  }

  @override
  List<Object?> get props => [
    track,
    playing,
    buffering,
    position,
    duration,
    volume,
  ];
}
