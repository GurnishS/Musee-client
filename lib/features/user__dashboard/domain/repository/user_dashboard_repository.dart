import 'package:musee/features/user__dashboard/domain/entities/dashboard_album.dart';

abstract interface class UserDashboardRepository {
  Future<PagedDashboardAlbums> getMadeForYou({int page, int limit});
  Future<PagedDashboardAlbums> getTrending({int page, int limit});
}
