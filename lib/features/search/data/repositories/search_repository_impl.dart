import 'package:musee/core/error/failures.dart';
import 'package:musee/features/search/data/datasources/search_remote_data_source.dart';
import 'package:musee/features/search/domain/entities/search_result.dart';
import 'package:musee/features/search/domain/entities/suggestion.dart';
import 'package:musee/features/search/domain/repository/search_repository.dart';
import 'package:fpdart/fpdart.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Suggestion>>> getSuggestions(String query) async {
    try {
      final suggestions = await remoteDataSource.getSuggestions(query);
      return Right(suggestions);
    } catch (error) {
      return Left(Failure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SearchResult>>> searchQuery(String query) {
    try {
      return remoteDataSource
          .searchQuery(query)
          .then((videos) => Right(videos));
    } catch (error) {
      return Future.value(Left(Failure(error.toString())));
    }
  }
}
