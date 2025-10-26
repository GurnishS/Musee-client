import 'package:fpdart/fpdart.dart';
import 'package:musee/core/common/entities/user.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import 'package:musee/features/admin_users/domain/repository/admin_repository.dart';

class ListUsers
    implements UseCase<(List<User>, int, int, int), ListUsersParams> {
  final AdminRepository repo;
  ListUsers(this.repo);

  @override
  Future<Either<Failure, (List<User>, int, int, int)>> call(
    ListUsersParams params,
  ) {
    return repo.listUsers(
      page: params.page,
      limit: params.limit,
      search: params.search,
    );
  }
}

class ListUsersParams {
  final int page;
  final int limit;
  final String? search;

  const ListUsersParams({this.page = 1, this.limit = 20, this.search});
}
