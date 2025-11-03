import 'package:equatable/equatable.dart';

class DashboardAlbum extends Equatable {
  final String albumId;
  final String title;
  final String? coverUrl;
  final int? duration;
  final List<DashboardArtist> artists;

  const DashboardAlbum({
    required this.albumId,
    required this.title,
    required this.coverUrl,
    required this.duration,
    required this.artists,
  });

  @override
  List<Object?> get props => [albumId, title, coverUrl, duration, artists];
}

class DashboardArtist extends Equatable {
  final String artistId;
  final String name;
  final String? avatarUrl;

  const DashboardArtist({
    required this.artistId,
    required this.name,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [artistId, name, avatarUrl];
}

class PagedDashboardAlbums extends Equatable {
  final List<DashboardAlbum> items;
  final int total;
  final int page;
  final int limit;

  const PagedDashboardAlbums({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [items, total, page, limit];
}
