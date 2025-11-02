import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import '../repository/admin_tracks_repository.dart';

class UpdateTrackArtistRole {
  final AdminTracksRepository _repo;
  UpdateTrackArtistRole(this._repo);

  Future<Either<Failure, void>> call(UpdateTrackArtistRoleParams params) {
    return _repo.updateTrackArtistRole(
      trackId: params.trackId,
      artistId: params.artistId,
      role: params.role,
    );
  }
}

class UpdateTrackArtistRoleParams {
  final String trackId;
  final String artistId;
  final String role; // owner|editor|viewer
  UpdateTrackArtistRoleParams({
    required this.trackId,
    required this.artistId,
    required this.role,
  });
}
