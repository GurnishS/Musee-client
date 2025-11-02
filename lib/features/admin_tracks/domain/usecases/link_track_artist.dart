import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import '../repository/admin_tracks_repository.dart';

class LinkTrackArtist {
  final AdminTracksRepository _repo;
  LinkTrackArtist(this._repo);

  Future<Either<Failure, void>> call(LinkTrackArtistParams params) {
    return _repo.linkArtistToTrack(
      trackId: params.trackId,
      artistId: params.artistId,
      role: params.role,
    );
  }
}

class LinkTrackArtistParams {
  final String trackId;
  final String artistId;
  final String role; // owner|editor|viewer
  LinkTrackArtistParams({
    required this.trackId,
    required this.artistId,
    required this.role,
  });
}
