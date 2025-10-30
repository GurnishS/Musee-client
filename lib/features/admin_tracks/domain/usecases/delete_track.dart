import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../repository/admin_tracks_repository.dart';

class DeleteTrackParams {
  final String id;
  const DeleteTrackParams(this.id);
}

class DeleteTrack implements UseCase<void, DeleteTrackParams> {
  final AdminTracksRepository repo;
  DeleteTrack(this.repo);

  @override
  Future<Either<Failure, void>> call(DeleteTrackParams params) {
    return repo.deleteTrack(params.id);
  }
}
