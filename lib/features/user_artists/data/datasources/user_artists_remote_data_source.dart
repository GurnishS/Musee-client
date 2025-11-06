import 'package:dio/dio.dart' as dio;
import 'package:musee/core/secrets/app_secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class UserArtistDTO {
  final String artistId;
  final String? name;
  final String? avatarUrl;
  final String? coverUrl;
  final String? bio;
  final List<String> genres;
  final int? monthlyListeners;

  UserArtistDTO({
    required this.artistId,
    this.name,
    this.avatarUrl,
    this.coverUrl,
    this.bio,
    this.genres = const [],
    this.monthlyListeners,
  });

  factory UserArtistDTO.fromJson(Map<String, dynamic> json) {
    return UserArtistDTO(
      artistId: (json['artist_id'] ?? json['id']).toString(),
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      bio: json['bio'] as String?,
      genres:
          (json['genres'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      monthlyListeners: (json['monthly_listeners'] as num?)?.toInt(),
    );
  }
}

class UserArtistAlbumDTO {
  final String albumId;
  final String title;
  final String? coverUrl;
  final String? releaseDate;

  UserArtistAlbumDTO({
    required this.albumId,
    required this.title,
    this.coverUrl,
    this.releaseDate,
  });

  factory UserArtistAlbumDTO.fromJson(Map<String, dynamic> json) {
    return UserArtistAlbumDTO(
      albumId: (json['album_id'] ?? json['id']).toString(),
      title: json['title']?.toString() ?? '',
      coverUrl: json['cover_url'] as String?,
      releaseDate: json['release_date'] as String?,
    );
  }
}

abstract interface class UserArtistsRemoteDataSource {
  Future<UserArtistDTO> getArtist(String artistId);
  Future<List<UserArtistAlbumDTO>> getArtistAlbums(String artistId);
}

class UserArtistsRemoteDataSourceImpl implements UserArtistsRemoteDataSource {
  final dio.Dio _dio;
  final supa.SupabaseClient supabase;
  final String baseArtistsPath;

  UserArtistsRemoteDataSourceImpl(this._dio, this.supabase)
    : baseArtistsPath = '${AppSecrets.backendUrl}/api/user/artists';

  Map<String, String> _authHeader() {
    final token = supabase.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Missing Supabase access token for user API request');
    }
    return {'Authorization': 'Bearer $token'};
  }

  @override
  Future<UserArtistDTO> getArtist(String artistId) async {
    final res = await _dio.get(
      '$baseArtistsPath/$artistId',
      options: dio.Options(headers: _authHeader()),
    );
    return UserArtistDTO.fromJson(Map<String, dynamic>.from(res.data));
  }

  @override
  Future<List<UserArtistAlbumDTO>> getArtistAlbums(String artistId) async {
    // Assumption: backend exposes this route; falls back to filtering albums list by artist_id if needed in future.
    final res = await _dio.get(
      '$baseArtistsPath/$artistId/albums',
      options: dio.Options(headers: _authHeader()),
    );
    final data = res.data;
    List<dynamic> items;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['items'] is List) {
        items = (map['items'] as List).cast<dynamic>();
      } else if (map['data'] is List) {
        items = (map['data'] as List).cast<dynamic>();
      } else {
        items = const [];
      }
    } else if (data is List) {
      items = data;
    } else {
      items = const [];
    }
    return items
        .map((e) => UserArtistAlbumDTO.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
