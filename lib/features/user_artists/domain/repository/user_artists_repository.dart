import 'package:musee/features/user_artists/domain/entities/user_artist.dart';

abstract interface class UserArtistsRepository {
  Future<UserArtistDetail> getArtist(String artistId);
}
