import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/track.dart';
import '../repository/admin_tracks_repository.dart';

class CreateTrackParams {
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

  const CreateTrackParams({
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

class CreateTrack implements UseCase<Track, CreateTrackParams> {
  final AdminTracksRepository repo;
  CreateTrack(this.repo);

  @override
  Future<Either<Failure, Track>> call(CreateTrackParams params) {
    return repo.createTrack(
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
