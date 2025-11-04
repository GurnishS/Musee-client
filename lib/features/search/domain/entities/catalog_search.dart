class CatalogArtist {
  final String artistId;
  final String? name;
  final String? avatarUrl;

  CatalogArtist({required this.artistId, this.name, this.avatarUrl});
}

class CatalogAlbum {
  final String albumId;
  final String title;
  final String? coverUrl;
  final List<CatalogArtist> artists;

  CatalogAlbum({
    required this.albumId,
    required this.title,
    this.coverUrl,
    this.artists = const [],
  });
}

class CatalogTrack {
  final String trackId;
  final String title;
  final int? duration;
  final List<CatalogArtist> artists;

  CatalogTrack({
    required this.trackId,
    required this.title,
    this.duration,
    this.artists = const [],
  });
}

class CatalogSearchResults {
  final List<CatalogTrack> tracks;
  final List<CatalogAlbum> albums;
  final List<CatalogArtist> artists;

  const CatalogSearchResults({
    this.tracks = const [],
    this.albums = const [],
    this.artists = const [],
  });

  bool get isEmpty => tracks.isEmpty && albums.isEmpty && artists.isEmpty;
}
