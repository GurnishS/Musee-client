import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/track.dart';
import '../repository/admin_tracks_repository.dart';

class UpdateTrackParams {
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

  const UpdateTrackParams({
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

class UpdateTrack implements UseCase<Track, UpdateTrackParams> {
  final AdminTracksRepository repo;
  UpdateTrack(this.repo);

  @override
  Future<Either<Failure, Track>> call(UpdateTrackParams params) {
    return repo.updateTrack(
      id: params.id,
      title: params.title,
      albumId: params.albumId,
      duration: params.duration,
      lyricsUrl: params.lyricsUrl,
      isExplicit: params.isExplicit,
      isPublished: params.isPublished,
      audioBytes: params.audioBytes,
      audioFilename: params.audioFilename,
      coverBytes: params.coverBytes,
      coverFilename: params.coverFilename,
      videoBytes: params.videoBytes,
      videoFilename: params.videoFilename,
    );
  }
}
