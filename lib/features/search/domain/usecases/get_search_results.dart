import 'package:musee/core/error/failures.dart';
import 'package:musee/features/search/domain/entities/search_result.dart';
import 'package:musee/features/search/domain/repository/search_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetSearchResults {
  final SearchRepository repository;

  GetSearchResults(this.repository);

  Future<Either<Failure, List<SearchResult>>> call(String query) {
    return repository.searchQuery(query);
  }
}
