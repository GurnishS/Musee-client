import 'package:dio/dio.dart' as dio;
import 'package:musee/core/secrets/app_secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class UserAlbumDetailDTO {
  final String albumId;
  final String title;
  final String? coverUrl;
  final String? releaseDate; // YYYY-MM-DD
  final List<UserAlbumArtistDTO> artists;
  final List<UserAlbumTrackDTO> tracks;

  UserAlbumDetailDTO({
    required this.albumId,
    required this.title,
    required this.coverUrl,
    required this.releaseDate,
    required this.artists,
    required this.tracks,
  });

  factory UserAlbumDetailDTO.fromJson(Map<String, dynamic> json) {
    return UserAlbumDetailDTO(
      albumId: json['album_id'] as String,
      title: json['title'] as String,
      coverUrl: json['cover_url'] as String?,
      releaseDate: json['release_date'] as String?,
      artists: (json['artists'] as List<dynamic>? ?? const [])
          .map((e) => UserAlbumArtistDTO.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      tracks: (json['tracks'] as List<dynamic>? ?? const [])
          .map((e) => UserAlbumTrackDTO.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class UserAlbumArtistDTO {
  final String artistId;
  final String? name;
  final String? avatarUrl;

  UserAlbumArtistDTO({required this.artistId, this.name, this.avatarUrl});

  factory UserAlbumArtistDTO.fromJson(Map<String, dynamic> json) {
    return UserAlbumArtistDTO(
      artistId: json['artist_id'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class UserAlbumTrackDTO {
  final String trackId;
  final String title;
  final int duration; // seconds
  final bool isExplicit;
  final List<UserAlbumArtistDTO> artists;

  UserAlbumTrackDTO({
    required this.trackId,
    required this.title,
    required this.duration,
    required this.isExplicit,
    required this.artists,
  });

  factory UserAlbumTrackDTO.fromJson(Map<String, dynamic> json) {
    return UserAlbumTrackDTO(
      trackId: json['track_id'] as String,
      title: json['title'] as String,
      duration: (json['duration'] ?? 0) as int,
      isExplicit: (json['is_explicit'] ?? false) as bool,
      artists: (json['artists'] as List<dynamic>? ?? const [])
          .map((e) => UserAlbumArtistDTO.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

abstract interface class UserAlbumsRemoteDataSource {
  Future<UserAlbumDetailDTO> getAlbum(String albumId);
}

class UserAlbumsRemoteDataSourceImpl implements UserAlbumsRemoteDataSource {
  final dio.Dio _dio;
  final supa.SupabaseClient supabase;
  final String basePath;

  UserAlbumsRemoteDataSourceImpl(this._dio, this.supabase)
    : basePath = '${AppSecrets.backendUrl}/api/user/albums';

  Map<String, String> _authHeader() {
    final token = supabase.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Missing Supabase access token for user API request');
    }
    return {'Authorization': 'Bearer $token'};
  }

  @override
  Future<UserAlbumDetailDTO> getAlbum(String albumId) async {
    final res = await _dio.get(
      '$basePath/$albumId',
      options: dio.Options(headers: _authHeader()),
    );
    return UserAlbumDetailDTO.fromJson(Map<String, dynamic>.from(res.data));
  }
}
