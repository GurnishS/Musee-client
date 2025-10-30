import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import '../entities/track.dart';

abstract class AdminTracksRepository {
  Future<Either<Failure, (List<Track> items, int total, int page, int limit)>>
  listTracks({int page = 0, int limit = 20, String? q});

  Future<Either<Failure, Track>> getTrack(String id);

  Future<Either<Failure, Track>> createTrack({
    required String title,
    required String albumId,
    required int duration,
    String? lyricsUrl,
    bool? isExplicit,
    bool? isPublished,
    List<int>? audioBytes,
    String? audioFilename,
    List<int>? coverBytes,
    String? coverFilename,
    List<int>? videoBytes,
    String? videoFilename,
  });

  Future<Either<Failure, Track>> updateTrack({
    required String id,
    String? title,
    String? albumId,
    int? duration,
    String? lyricsUrl,
    bool? isExplicit,
    bool? isPublished,
    List<int>? audioBytes,
    String? audioFilename,
    List<int>? coverBytes,
    String? coverFilename,
    List<int>? videoBytes,
    String? videoFilename,
  });

  Future<Either<Failure, void>> deleteTrack(String id);
}
