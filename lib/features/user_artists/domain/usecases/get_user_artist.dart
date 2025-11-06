import 'package:musee/features/user_artists/domain/entities/user_artist.dart';
import 'package:musee/features/user_artists/domain/repository/user_artists_repository.dart';

class GetUserArtist {
  final UserArtistsRepository _repo;
  GetUserArtist(this._repo);

  Future<UserArtistDetail> call(String artistId) => _repo.getArtist(artistId);
}
