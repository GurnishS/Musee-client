import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/artist.dart';
import '../repository/admin_artists_repository.dart';

class UpdateArtistParams {
  final String id;
  final String? bio;
  final String? coverUrl;
  final List<int>? coverBytes;
  final String? coverFilename;
  final List<String>? genres;
  final int? debutYear;
  final bool? isVerified;
  final Map<String, dynamic>? socialLinks;
  final int? monthlyListeners;
  final String? regionId;
  final DateTime? dateOfBirth;

  const UpdateArtistParams({
    required this.id,
    this.bio,
    this.coverUrl,
    this.coverBytes,
    this.coverFilename,
    this.genres,
    this.debutYear,
    this.isVerified,
    this.socialLinks,
    this.monthlyListeners,
    this.regionId,
    this.dateOfBirth,
  });
}

class UpdateArtist implements UseCase<Artist, UpdateArtistParams> {
  final AdminArtistsRepository repo;
  UpdateArtist(this.repo);

  @override
  Future<Either<Failure, Artist>> call(UpdateArtistParams params) {
    return repo.updateArtist(
      id: params.id,
      bio: params.bio,
      coverUrl: params.coverUrl,
      coverBytes: params.coverBytes,
      coverFilename: params.coverFilename,
      genres: params.genres,
      debutYear: params.debutYear,
      isVerified: params.isVerified,
      socialLinks: params.socialLinks,
      monthlyListeners: params.monthlyListeners,
      regionId: params.regionId,
      dateOfBirth: params.dateOfBirth,
    );
  }
}
