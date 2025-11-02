import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import '../repository/admin_tracks_repository.dart';

class UnlinkTrackArtist {
  final AdminTracksRepository _repo;
  UnlinkTrackArtist(this._repo);

  Future<Either<Failure, void>> call(UnlinkTrackArtistParams params) {
    return _repo.unlinkArtistFromTrack(
      trackId: params.trackId,
      artistId: params.artistId,
    );
  }
}

class UnlinkTrackArtistParams {
  final String trackId;
  final String artistId;
  UnlinkTrackArtistParams({required this.trackId, required this.artistId});
}
