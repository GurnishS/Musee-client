part of 'search_bloc.dart';

@immutable
sealed class SearchState {
  const SearchState();
}

final class SearchInitial extends SearchState {}

final class SearchLoading extends SearchState {}

final class SearchQueryLoading extends SearchState {}

final class SearchResultsLoaded extends SearchState {
  final List<SearchResult> results;
  const SearchResultsLoaded(this.results);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchResultsLoaded && other.results == results;
  }

  @override
  int get hashCode => results.hashCode;
}

class VideosError extends SearchState {
  final String message;
  const VideosError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideosError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

final class SuggestionLoading extends SearchState {}

class SuggestionError extends SearchState {
  final String message;
  const SuggestionError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideosError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class SuggestionLoaded extends SearchState {
  final List<Suggestion> suggestions;
  const SuggestionLoaded(this.suggestions);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuggestionLoaded && other.suggestions == suggestions;
  }

  @override
  int get hashCode => suggestions.hashCode;
}

final class SearchTestInitial extends SearchState {}

class SearchTestError extends SearchState {
  final String message;
  const SearchTestError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchTestError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

class SearchTestLoaded extends SearchState {
  final String query;
  const SearchTestLoaded(this.query);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchTestLoaded && other.query == query;
  }

  @override
  int get hashCode => query.hashCode;
}
