import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/artist.dart';
import '../repository/admin_artists_repository.dart';

class GetArtist implements UseCase<Artist, String> {
  final AdminArtistsRepository repo;
  GetArtist(this.repo);

  @override
  Future<Either<Failure, Artist>> call(String id) => repo.getArtist(id);
}
