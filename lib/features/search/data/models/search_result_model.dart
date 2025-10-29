import 'package:musee/features/search/domain/entities/search_result.dart';

/// Data model for search results that extends the domain entity
/// Handles JSON serialization/deserialization for API communication
class SearchResultModel extends SearchResult {
  /// Creates a SearchResultModel instance
  SearchResultModel({
    required super.title,
    required super.type,
    required super.extractorKey,
    required super.results,
  });

  /// Creates a SearchResultModel from JSON data
  /// Throws [FormatException] if JSON structure is invalid
  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    try {
      return SearchResultModel(
        title: _parseString(json, 'title'),
        type: _parseString(json, 'type'),
        extractorKey: _parseString(json, 'extractor_key'),
        results: _parseSearchItems(json, 'results'),
      );
    } catch (e) {
      throw FormatException('Failed to parse SearchResultModel: $e');
    }
  }

  /// Converts the model to JSON format for API requests
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'extractor_key': extractorKey,
      'results': results
          .map((item) => (item as SearchItemModel).toJson())
          .toList(),
    };
  }

  /// Safely parses a string field from JSON
  static String _parseString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException(
        'Expected string for key "$key", got ${value.runtimeType}',
      );
    }
    return value;
  }

  /// Safely parses search items list from JSON
  static List<SearchItem> _parseSearchItems(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value is! List) {
      throw FormatException(
        'Expected list for key "$key", got ${value.runtimeType}',
      );
    }

    return value.map((item) {
      if (item is! Map<String, dynamic>) {
        throw FormatException(
          'Expected Map<String, dynamic> for search item, got ${item.runtimeType}',
        );
      }
      return SearchItemModel.fromJson(item);
    }).toList();
  }

  /// Creates a copy of this model with updated values
  SearchResultModel copyWith({
    String? title,
    String? type,
    String? extractorKey,
    List<SearchItem>? results,
  }) {
    return SearchResultModel(
      title: title ?? this.title,
      type: type ?? this.type,
      extractorKey: extractorKey ?? this.extractorKey,
      results: results ?? this.results,
    );
  }

  @override
  String toString() {
    return 'SearchResultModel(title: $title, type: $type, extractorKey: $extractorKey, resultsCount: ${results.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResultModel &&
        other.title == title &&
        other.type == type &&
        other.extractorKey == extractorKey &&
        _listEquals(other.results, results);
  }

  @override
  int get hashCode {
    return Object.hash(title, type, extractorKey, results);
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}

/// Data model for individual search items that extends the domain entity
/// Represents a single video/content item in search results
class SearchItemModel extends SearchItem {
  /// Creates a SearchItemModel instance
  SearchItemModel({
    required super.id,
    required super.title,
    required super.url,
    super.description,
    super.thumbnail,
    super.duration,
    super.uploader,
    super.uploadDate,
  });

  /// Creates a SearchItemModel from JSON data
  /// Throws [FormatException] if JSON structure is invalid
  factory SearchItemModel.fromJson(Map<String, dynamic> json) {
    try {
      return SearchItemModel(
        id: _parseString(json, 'id'),
        title: _parseString(json, 'title'),
        url: _parseString(json, 'url'),
        description: _parseNullableString(json, 'description'),
        thumbnail: _parseNullableString(json, 'thumbnail'),
        duration: _parseNullableInt(json, 'duration'),
        uploader: _parseNullableString(json, 'uploader'),
        uploadDate: _parseNullableString(json, 'upload_date'),
      );
    } catch (e) {
      throw FormatException('Failed to parse SearchItemModel: $e');
    }
  }

  /// Converts the model to JSON format for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'description': description,
      'thumbnail': thumbnail,
      'duration': duration,
      'uploader': uploader,
      'upload_date': uploadDate,
    };
  }

  /// Safely parses a required string field from JSON
  static String _parseString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw FormatException(
        'Expected string for key "$key", got ${value.runtimeType}',
      );
    }
    return value;
  }

  /// Safely parses an optional string field from JSON
  static String? _parseNullableString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    throw FormatException(
      'Expected string or null for key "$key", got ${value.runtimeType}',
    );
  }

  /// Safely parses an optional integer field from JSON
  static int? _parseNullableInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException(
      'Expected int, string number, or null for key "$key", got ${value.runtimeType}',
    );
  }

  /// Creates a copy of this model with updated values
  SearchItemModel copyWith({
    String? id,
    String? title,
    String? url,
    String? description,
    String? thumbnail,
    int? duration,
    String? uploader,
    String? uploadDate,
  }) {
    return SearchItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      uploader: uploader ?? this.uploader,
      uploadDate: uploadDate ?? this.uploadDate,
    );
  }

  @override
  String toString() {
    return 'SearchItemModel(id: $id, title: $title, uploader: $uploader, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchItemModel &&
        other.id == id &&
        other.title == title &&
        other.url == url &&
        other.description == description &&
        other.thumbnail == thumbnail &&
        other.duration == duration &&
        other.uploader == uploader &&
        other.uploadDate == uploadDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      url,
      description,
      thumbnail,
      duration,
      uploader,
      uploadDate,
    );
  }
}
