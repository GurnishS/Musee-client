import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/album.dart';
import '../repository/admin_albums_repository.dart';

class ListAlbumsParams {
  final int page;
  final int limit;
  final String? q;
  const ListAlbumsParams({this.page = 0, this.limit = 20, this.q});
}

class ListAlbums
    implements UseCase<(List<Album>, int, int, int), ListAlbumsParams> {
  final AdminAlbumsRepository repo;
  ListAlbums(this.repo);

  @override
  Future<Either<Failure, (List<Album>, int, int, int)>> call(
    ListAlbumsParams params,
  ) {
    return repo.listAlbums(page: params.page, limit: params.limit, q: params.q);
  }
}
