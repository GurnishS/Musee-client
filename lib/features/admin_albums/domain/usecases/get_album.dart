import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/album.dart';
import '../repository/admin_albums_repository.dart';

class GetAlbum implements UseCase<Album, String> {
  final AdminAlbumsRepository repo;
  GetAlbum(this.repo);

  @override
  Future<Either<Failure, Album>> call(String id) => repo.getAlbum(id);
}
