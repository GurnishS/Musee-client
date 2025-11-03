import 'package:musee/features/user__dashboard/data/datasources/user_dashboard_remote_data_source.dart';
import 'package:musee/features/user__dashboard/domain/entities/dashboard_album.dart';
import 'package:musee/features/user__dashboard/domain/repository/user_dashboard_repository.dart';

class UserDashboardRepositoryImpl implements UserDashboardRepository {
  final UserDashboardRemoteDataSource _remote;
  UserDashboardRepositoryImpl(this._remote);

  DashboardArtist _mapArtist(DashboardArtistDTO a) => DashboardArtist(
    artistId: a.artistId,
    name: a.name,
    avatarUrl: a.avatarUrl,
  );

  DashboardAlbum _mapAlbum(DashboardAlbumDTO d) => DashboardAlbum(
    albumId: d.albumId,
    title: d.title,
    coverUrl: d.coverUrl,
    duration: d.duration,
    artists: d.artists.map(_mapArtist).toList(),
  );

  PagedDashboardAlbums _mapPaged(PagedDashboardAlbumsDTO dto) {
    return PagedDashboardAlbums(
      items: dto.items.map(_mapAlbum).toList(),
      total: dto.total,
      page: dto.page,
      limit: dto.limit,
    );
  }

  @override
  Future<PagedDashboardAlbums> getMadeForYou({
    int page = 0,
    int limit = 20,
  }) async {
    final dto = await _remote.getMadeForYou(page: page, limit: limit);
    return _mapPaged(dto);
  }

  @override
  Future<PagedDashboardAlbums> getTrending({
    int page = 0,
    int limit = 20,
  }) async {
    final dto = await _remote.getTrending(page: page, limit: limit);
    return _mapPaged(dto);
  }
}
