import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/album.dart';
import '../repository/admin_albums_repository.dart';

class UpdateAlbumParams {
  final String id;
  final String? title;
  final String? description;
  final List<String>? genres;
  final bool? isPublished;
  final List<int>? coverBytes;
  final String? coverFilename;

  const UpdateAlbumParams({
    required this.id,
    this.title,
    this.description,
    this.genres,
    this.isPublished,
    this.coverBytes,
    this.coverFilename,
  });
}

class UpdateAlbum implements UseCase<Album, UpdateAlbumParams> {
  final AdminAlbumsRepository repo;
  UpdateAlbum(this.repo);

  @override
  Future<Either<Failure, Album>> call(UpdateAlbumParams params) {
    return repo.updateAlbum(
      id: params.id,
      title: params.title,
      description: params.description,
      genres: params.genres,
      isPublished: params.isPublished,
      coverBytes: params.coverBytes,
      coverFilename: params.coverFilename,
    );
  }
}
