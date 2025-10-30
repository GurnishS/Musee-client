part of 'admin_tracks_bloc.dart';

abstract class AdminTracksEvent {}

class LoadTracks extends AdminTracksEvent {
  final int page;
  final int limit;
  final String? search;

  LoadTracks({this.page = 0, this.limit = 20, this.search});
}

class CreateTrackEvent extends AdminTracksEvent {
  final String title;
  final String albumId;
  final int duration;
  final String? lyricsUrl;
  final bool? isExplicit;
  final bool? isPublished;
  final List<int>? audioBytes;
  final String? audioFilename;
  final List<int>? coverBytes;
  final String? coverFilename;
  final List<int>? videoBytes;
  final String? videoFilename;

  CreateTrackEvent({
    required this.title,
    required this.albumId,
    required this.duration,
    this.lyricsUrl,
    this.isExplicit,
    this.isPublished,
    this.audioBytes,
    this.audioFilename,
    this.coverBytes,
    this.coverFilename,
    this.videoBytes,
    this.videoFilename,
  });
}

class UpdateTrackEvent extends AdminTracksEvent {
  final String id;
  final String? title;
  final String? albumId;
  final int? duration;
  final String? lyricsUrl;
  final bool? isExplicit;
  final bool? isPublished;
  final List<int>? audioBytes;
  final String? audioFilename;
  final List<int>? coverBytes;
  final String? coverFilename;
  final List<int>? videoBytes;
  final String? videoFilename;

  UpdateTrackEvent({
    required this.id,
    this.title,
    this.albumId,
    this.duration,
    this.lyricsUrl,
    this.isExplicit,
    this.isPublished,
    this.audioBytes,
    this.audioFilename,
    this.coverBytes,
    this.coverFilename,
    this.videoBytes,
    this.videoFilename,
  });
}

class DeleteTrackEvent extends AdminTracksEvent {
  final String id;
  DeleteTrackEvent(this.id);
}
