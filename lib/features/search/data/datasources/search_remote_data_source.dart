import 'package:musee/core/secrets/app_secrets.dart';
import 'package:musee/features/search/data/models/suggestion_model.dart';
import 'package:musee/features/search/data/models/catalog_search_models.dart';
import 'package:musee/features/search/domain/entities/catalog_search.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract interface class SearchRemoteDataSource {
  Session? get currentSession;
  Future<List<SuggestionModel>> getSuggestions(String query);
  Future<CatalogSearchResults> searchCatalog(
    String query, {
    int perSectionLimit = 5,
  });
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final SupabaseClient supabaseClient;

  SearchRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentSession => supabaseClient.auth.currentSession;

  @override
  Future<List<SuggestionModel>> getSuggestions(String query) async {
    try {
      // Aggregate suggestions from tracks, albums, and artists endpoints
      final token = currentSession?.accessToken;
      final Map<String, String> headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : {};
      final q = Uri.encodeQueryComponent(query);

      final uris = [
        Uri.parse(
          '${AppSecrets.backendUrl}/api/user/tracks?page=0&limit=3&q=$q',
        ),
        Uri.parse(
          '${AppSecrets.backendUrl}/api/user/albums?page=0&limit=3&q=$q',
        ),
        Uri.parse(
          '${AppSecrets.backendUrl}/api/user/artists?page=0&limit=3&q=$q',
        ),
      ];

      final responses = await Future.wait(
        uris.map(
          (u) => http
              .get(u, headers: headers)
              .timeout(const Duration(seconds: 20)),
        ),
      );

      final suggestions = <String>{};

      // Tracks
      if (responses.isNotEmpty && responses[0].statusCode == 200) {
        final data = json.decode(responses[0].body);
        final items = _extractItems(data);
        for (final it in items) {
          final m = (it as Map).cast<String, dynamic>();
          final title = m['title']?.toString();
          if (title != null && title.isNotEmpty) suggestions.add(title);
        }
      }

      // Albums
      if (responses.length > 1 && responses[1].statusCode == 200) {
        final data = json.decode(responses[1].body);
        final items = _extractItems(data);
        for (final it in items) {
          final m = (it as Map).cast<String, dynamic>();
          final title = m['title']?.toString();
          if (title != null && title.isNotEmpty) suggestions.add(title);
        }
      }

      // Artists
      if (responses.length > 2 && responses[2].statusCode == 200) {
        final data = json.decode(responses[2].body);
        final items = _extractItems(data);
        for (final it in items) {
          final m = (it as Map).cast<String, dynamic>();
          final name = m['name']?.toString();
          if (name != null && name.isNotEmpty) suggestions.add(name);
        }
      }

      if (suggestions.isNotEmpty) {
        return suggestions
            .take(10)
            .map((s) => SuggestionModel.fromJson(s))
            .toList();
      }
      return _getFallbackSuggestions(query);
    } catch (e) {
      return _getFallbackSuggestions(query);
    }
  }

  List<SuggestionModel> _getFallbackSuggestions(String query) {
    if (query.isEmpty) return [];

    // Generate intelligent fallback suggestions
    final suggestions = [
      '$query song',
      '$query music',
      '$query video',
      '$query tutorial',
      '$query movies',
      '$query dance',
      '$query new',
      '$query latest',
    ];

    return suggestions.map((s) => SuggestionModel.fromJson(s)).toList();
  }

  @override
  Future<CatalogSearchResults> searchCatalog(
    String query, {
    int perSectionLimit = 5,
  }) async {
    try {
      final token = currentSession?.accessToken;
      final Map<String, String> headers = token != null
          ? {'Authorization': 'Bearer $token'}
          : {};
      final q = Uri.encodeQueryComponent(query);
      final limit = perSectionLimit.clamp(1, 20);

      final tracksUri = Uri.parse(
        '${AppSecrets.backendUrl}/api/user/tracks?page=0&limit=$limit&q=$q',
      );
      final albumsUri = Uri.parse(
        '${AppSecrets.backendUrl}/api/user/albums?page=0&limit=$limit&q=$q',
      );
      final artistsUri = Uri.parse(
        '${AppSecrets.backendUrl}/api/user/artists?page=0&limit=$limit&q=$q',
      );

      final responses = await Future.wait(
        [
          http.get(tracksUri, headers: headers),
          http.get(albumsUri, headers: headers),
          http.get(artistsUri, headers: headers),
        ].map((f) => f.timeout(const Duration(seconds: 30))),
      );

      List<dynamic> tracks = const [];
      List<dynamic> albums = const [];
      List<dynamic> artists = const [];

      if (responses[0].statusCode == 200) {
        final obj = json.decode(responses[0].body);
        tracks = _extractItems(obj);
      }
      if (responses[1].statusCode == 200) {
        final obj = json.decode(responses[1].body);
        albums = _extractItems(obj);
      }
      if (responses[2].statusCode == 200) {
        final obj = json.decode(responses[2].body);
        artists = _extractItems(obj);
      }

      return CatalogSearchResultsModel.fromThreeLists(
        tracks: tracks,
        albums: albums,
        artists: artists,
      );
    } catch (e) {
      if (kDebugMode) print('Catalog search exception: $e');
      return const CatalogSearchResults();
    }
  }
}

/// Extract a list of items from various common response envelopes.
/// Supports:
/// - { items: [...] }
/// - { data: [...] }
/// - { results: [...] }
/// - [ ... ] (bare array)
List<dynamic> _extractItems(dynamic decoded) {
  if (decoded is List) return decoded;
  if (decoded is Map<String, dynamic>) {
    final map = decoded;
    final items = map['items'];
    if (items is List) return items;
    final data = map['data'];
    if (data is List) return data;
    final results = map['results'];
    if (results is List) return results;
  }
  return const [];
}
