import 'package:musee/core/error/failures.dart';
import 'package:musee/features/search/domain/entities/search_result.dart';
import 'package:musee/features/search/domain/entities/suggestion.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class SearchRepository {
  Future<Either<Failure, List<Suggestion>>> getSuggestions(String query);
  Future<Either<Failure, List<SearchResult>>> searchQuery(String query);
}
