import 'package:musee/features/user_albums/data/datasources/user_albums_remote_data_source.dart';
import 'package:musee/features/user_albums/domain/entities/user_album.dart';
import 'package:musee/features/user_albums/domain/repository/user_albums_repository.dart';

class UserAlbumsRepositoryImpl implements UserAlbumsRepository {
  final UserAlbumsRemoteDataSource _remote;
  UserAlbumsRepositoryImpl(this._remote);

  @override
  Future<UserAlbumDetail> getAlbum(String albumId) async {
    final dto = await _remote.getAlbum(albumId);
    return UserAlbumDetail(
      albumId: dto.albumId,
      title: dto.title,
      coverUrl: dto.coverUrl,
      releaseDate: dto.releaseDate,
      artists: dto.artists
          .map(
            (a) => UserAlbumArtist(
              artistId: a.artistId,
              name: a.name,
              avatarUrl: a.avatarUrl,
            ),
          )
          .toList(),
      tracks: dto.tracks
          .map(
            (t) => UserAlbumTrack(
              trackId: t.trackId,
              title: t.title,
              duration: t.duration,
              isExplicit: t.isExplicit,
              artists: t.artists
                  .map(
                    (a) => UserAlbumArtist(
                      artistId: a.artistId,
                      name: a.name,
                      avatarUrl: a.avatarUrl,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}
