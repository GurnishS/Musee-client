import 'package:equatable/equatable.dart';

class UserArtistDetail extends Equatable {
  final String artistId;
  final String? name;
  final String? avatarUrl;
  final String? coverUrl;
  final String? bio;
  final List<String> genres;
  final int? monthlyListeners;
  final List<UserArtistAlbum> albums;

  const UserArtistDetail({
    required this.artistId,
    this.name,
    this.avatarUrl,
    this.coverUrl,
    this.bio,
    this.genres = const [],
    this.monthlyListeners,
    this.albums = const [],
  });

  @override
  List<Object?> get props => [
    artistId,
    name,
    avatarUrl,
    coverUrl,
    bio,
    genres,
    monthlyListeners,
    albums,
  ];
}

class UserArtistAlbum extends Equatable {
  final String albumId;
  final String title;
  final String? coverUrl;
  final String? releaseDate;

  const UserArtistAlbum({
    required this.albumId,
    required this.title,
    this.coverUrl,
    this.releaseDate,
  });

  @override
  List<Object?> get props => [albumId, title, coverUrl, releaseDate];
}
