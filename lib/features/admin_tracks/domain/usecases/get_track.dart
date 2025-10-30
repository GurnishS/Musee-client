import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/track.dart';
import '../repository/admin_tracks_repository.dart';

class GetTrackParams {
  final String id;
  const GetTrackParams(this.id);
}

class GetTrack implements UseCase<Track, GetTrackParams> {
  final AdminTracksRepository repo;
  GetTrack(this.repo);

  @override
  Future<Either<Failure, Track>> call(GetTrackParams params) {
    return repo.getTrack(params.id);
  }
}
