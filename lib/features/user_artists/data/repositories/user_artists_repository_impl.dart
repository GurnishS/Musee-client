import 'package:musee/features/user_artists/data/datasources/user_artists_remote_data_source.dart';
import 'package:musee/features/user_artists/domain/entities/user_artist.dart';
import 'package:musee/features/user_artists/domain/repository/user_artists_repository.dart';

class UserArtistsRepositoryImpl implements UserArtistsRepository {
  final UserArtistsRemoteDataSource _remote;
  UserArtistsRepositoryImpl(this._remote);

  @override
  Future<UserArtistDetail> getArtist(String artistId) async {
    final artist = await _remote.getArtist(artistId);
    final albums = await _remote.getArtistAlbums(artistId);
    return UserArtistDetail(
      artistId: artist.artistId,
      name: artist.name,
      avatarUrl: artist.avatarUrl,
      coverUrl: artist.coverUrl,
      bio: artist.bio,
      genres: artist.genres,
      monthlyListeners: artist.monthlyListeners,
      albums: albums
          .map(
            (a) => UserArtistAlbum(
              albumId: a.albumId,
              title: a.title,
              coverUrl: a.coverUrl,
              releaseDate: a.releaseDate,
            ),
          )
          .toList(),
    );
  }
}
