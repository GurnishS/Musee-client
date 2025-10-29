// domain/usecases/get_suggestions.dart
import 'package:musee/core/error/failures.dart';
import 'package:musee/features/search/domain/entities/suggestion.dart';
import 'package:musee/features/search/domain/repository/search_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetSuggestions {
  final SearchRepository repository;

  GetSuggestions(this.repository);

  Future<Either<Failure, List<Suggestion>>> call(String query) {
    return repository.getSuggestions(query);
  }
}
