import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../repository/admin_artists_repository.dart';
import '../entities/artist.dart';

class ListArtistsParams {
  final int page;
  final int limit;
  final String? q;
  ListArtistsParams({this.page = 0, this.limit = 20, this.q});
}

class ListArtists
    implements
        UseCase<
          (List<Artist> items, int total, int page, int limit),
          ListArtistsParams
        > {
  final AdminArtistsRepository repo;
  ListArtists(this.repo);

  @override
  Future<Either<Failure, (List<Artist>, int, int, int)>> call(
    ListArtistsParams params,
  ) {
    return repo.listArtists(
      page: params.page,
      limit: params.limit,
      search: params.q,
    );
  }
}
