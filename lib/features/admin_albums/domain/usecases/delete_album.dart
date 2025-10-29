import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../repository/admin_albums_repository.dart';

class DeleteAlbum implements UseCase<void, String> {
  final AdminAlbumsRepository repo;
  DeleteAlbum(this.repo);

  @override
  Future<Either<Failure, void>> call(String id) => repo.deleteAlbum(id);
}
