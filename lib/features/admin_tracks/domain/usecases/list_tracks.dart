import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../repository/admin_tracks_repository.dart';
import '../entities/track.dart';

class ListTracksParams {
  final int page;
  final int limit;
  final String? q;

  const ListTracksParams({this.page = 0, this.limit = 20, this.q});
}

class ListTracks
    implements UseCase<(List<Track>, int, int, int), ListTracksParams> {
  final AdminTracksRepository repo;
  ListTracks(this.repo);

  @override
  Future<Either<Failure, (List<Track>, int, int, int)>> call(
    ListTracksParams params,
  ) {
    return repo.listTracks(page: params.page, limit: params.limit, q: params.q);
  }
}
