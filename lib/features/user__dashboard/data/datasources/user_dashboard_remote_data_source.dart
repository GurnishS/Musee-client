import 'package:dio/dio.dart' as dio;
import 'package:musee/core/secrets/app_secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class DashboardAlbumDTO {
  final String albumId;
  final String title;
  final String? coverUrl;
  final int? duration;
  final List<DashboardArtistDTO> artists;

  DashboardAlbumDTO({
    required this.albumId,
    required this.title,
    required this.coverUrl,
    required this.duration,
    required this.artists,
  });

  factory DashboardAlbumDTO.fromJson(Map<String, dynamic> json) {
    return DashboardAlbumDTO(
      albumId: json['album_id'] as String,
      title: json['title'] as String? ?? '',
      coverUrl: json['cover_url'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      artists: (json['artists'] as List<dynamic>? ?? const [])
          .map(
            (e) => DashboardArtistDTO.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList(),
    );
  }
}

class DashboardArtistDTO {
  final String artistId;
  final String name;
  final String? avatarUrl;

  DashboardArtistDTO({
    required this.artistId,
    required this.name,
    required this.avatarUrl,
  });

  factory DashboardArtistDTO.fromJson(Map<String, dynamic> json) {
    return DashboardArtistDTO(
      artistId: json['artist_id'] as String,
      name: json['name'] as String? ?? 'Artist',
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class PagedDashboardAlbumsDTO {
  final List<DashboardAlbumDTO> items;
  final int total;
  final int page;
  final int limit;

  PagedDashboardAlbumsDTO({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PagedDashboardAlbumsDTO.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? const [])
        .map(
          (e) =>
              DashboardAlbumDTO.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
    return PagedDashboardAlbumsDTO(
      items: items,
      total: (json['total'] as num?)?.toInt() ?? items.length,
      page: (json['page'] as num?)?.toInt() ?? 0,
      limit: (json['limit'] as num?)?.toInt() ?? items.length,
    );
  }
}

abstract interface class UserDashboardRemoteDataSource {
  Future<PagedDashboardAlbumsDTO> getMadeForYou({int page = 0, int limit = 20});
  Future<PagedDashboardAlbumsDTO> getTrending({int page = 0, int limit = 20});
}

class UserDashboardRemoteDataSourceImpl
    implements UserDashboardRemoteDataSource {
  final dio.Dio _dio;
  final supa.SupabaseClient _supabase;
  final String basePath;

  UserDashboardRemoteDataSourceImpl(this._dio, this._supabase)
    : basePath = '${AppSecrets.backendUrl}/api/user/dashboard';

  Map<String, String> _authHeader() {
    final token = _supabase.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Missing Supabase access token for user API request');
    }
    return {'Authorization': 'Bearer $token'};
  }

  @override
  Future<PagedDashboardAlbumsDTO> getMadeForYou({
    int page = 0,
    int limit = 20,
  }) async {
    final res = await _dio.get(
      '$basePath/made-for-you',
      queryParameters: {'page': page, 'limit': limit},
      options: dio.Options(headers: _authHeader()),
    );
    return PagedDashboardAlbumsDTO.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  @override
  Future<PagedDashboardAlbumsDTO> getTrending({
    int page = 0,
    int limit = 20,
  }) async {
    final res = await _dio.get(
      '$basePath/trending',
      queryParameters: {'page': page, 'limit': limit},
      options: dio.Options(headers: _authHeader()),
    );
    return PagedDashboardAlbumsDTO.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }
}
