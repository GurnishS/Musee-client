import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../repository/admin_albums_repository.dart';

class AddAlbumArtistParams {
  final String albumId;
  final String artistId;
  final String? role; // owner|editor|viewer
  const AddAlbumArtistParams({
    required this.albumId,
    required this.artistId,
    this.role,
  });
}

class AddAlbumArtist
    implements UseCase<Map<String, dynamic>, AddAlbumArtistParams> {
  final AdminAlbumsRepository repo;
  AddAlbumArtist(this.repo);
  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    AddAlbumArtistParams params,
  ) {
    return repo.addArtist(
      albumId: params.albumId,
      artistId: params.artistId,
      role: params.role,
    );
  }
}

class UpdateAlbumArtistRoleParams {
  final String albumId;
  final String artistId;
  final String role;
  const UpdateAlbumArtistRoleParams({
    required this.albumId,
    required this.artistId,
    required this.role,
  });
}

class UpdateAlbumArtistRole
    implements UseCase<Map<String, dynamic>, UpdateAlbumArtistRoleParams> {
  final AdminAlbumsRepository repo;
  UpdateAlbumArtistRole(this.repo);
  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    UpdateAlbumArtistRoleParams params,
  ) {
    return repo.updateArtistRole(
      albumId: params.albumId,
      artistId: params.artistId,
      role: params.role,
    );
  }
}

class RemoveAlbumArtistParams {
  final String albumId;
  final String artistId;
  const RemoveAlbumArtistParams({
    required this.albumId,
    required this.artistId,
  });
}

class RemoveAlbumArtist implements UseCase<void, RemoveAlbumArtistParams> {
  final AdminAlbumsRepository repo;
  RemoveAlbumArtist(this.repo);
  @override
  Future<Either<Failure, void>> call(RemoveAlbumArtistParams params) {
    return repo.removeArtist(
      albumId: params.albumId,
      artistId: params.artistId,
    );
  }
}
