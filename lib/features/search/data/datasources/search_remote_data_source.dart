import 'package:musee/core/secrets/app_secrets.dart';
import 'package:musee/features/search/data/models/search_result_model.dart';
import 'package:musee/features/search/data/models/suggestion_model.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract interface class SearchRemoteDataSource {
  Session? get currentSession;
  Future<List<SuggestionModel>> getSuggestions(String query);
  Future<List<SearchResultModel>> searchQuery(String query);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final SupabaseClient supabaseClient;

  SearchRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentSession => supabaseClient.auth.currentSession;

  @override
  Future<List<SuggestionModel>> getSuggestions(String query) async {
    try {
      // Make request to your backend API
      final url = Uri.parse(
        '${AppSecrets.backendUrl}/api/generic/suggestions?q=${Uri.encodeQueryComponent(query)}',
      );
      final response = await http
          .get(
            url,
            headers: {'Authorization': 'Bearer ${currentSession?.accessToken}'},
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw Exception('timeout');
            },
          );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded.containsKey('suggestions')) {
          final List<dynamic> suggestionsData = decoded['suggestions'];
          return suggestionsData
              .map(
                (suggestion) => SuggestionModel.fromJson(suggestion.toString()),
              )
              .toList();
        }
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
  Future<List<SearchResultModel>> searchQuery(String query) async {
    try {
      // Make request to your backend API
      final url = Uri.parse(
        '${AppSecrets.backendUrl}/api/generic/search?query=${Uri.encodeQueryComponent(query)}',
      );
      final response = await http
          .get(
            url,
            headers: {'Authorization': 'Bearer ${currentSession?.accessToken}'},
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw Exception('timeout');
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (kDebugMode) print('Search API response: $jsonData');

        // Check if the response has the expected structure
        if (jsonData.containsKey('results') && jsonData['results'] is List) {
          final List<dynamic> resultsArray = jsonData['results'];
          return resultsArray
              .map(
                (item) =>
                    SearchResultModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else {
          if (kDebugMode) print('Unexpected API response structure: $jsonData');
          return [];
        }
      } else {
        if (kDebugMode) {
          print('Search API error: ${response.statusCode} - ${response.body}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) print('Search exception: $e');
      return [];
    }
  }
}
