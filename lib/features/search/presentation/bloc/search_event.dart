part of 'search_bloc.dart';

@immutable
sealed class SearchEvent {}

/// Event for fetching suggestions
final class FetchSuggestions extends SearchEvent {
  final String query;
  FetchSuggestions({required this.query})
    : assert(query.isNotEmpty, 'Query cannot be empty');
}

class SearchQuery extends SearchEvent {
  final String query;
  SearchQuery({required this.query})
    : assert(query.isNotEmpty, 'Query cannot be empty');
}

class RunTest extends SearchEvent {
  final String query;
  RunTest({required this.query})
    : assert(query.isNotEmpty, 'Query cannot be empty');
}