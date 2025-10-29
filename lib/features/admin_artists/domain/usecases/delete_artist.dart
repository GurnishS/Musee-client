import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../repository/admin_artists_repository.dart';

class DeleteArtist implements UseCase<void, String> {
  final AdminArtistsRepository repo;
  DeleteArtist(this.repo);

  @override
  Future<Either<Failure, void>> call(String id) => repo.deleteArtist(id);
}
