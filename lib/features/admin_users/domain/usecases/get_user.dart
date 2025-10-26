import 'package:fpdart/fpdart.dart';
import 'package:musee/core/common/entities/user.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import 'package:musee/features/admin_users/domain/repository/admin_repository.dart';

class GetUser implements UseCase<User, String> {
  final AdminRepository repo;
  GetUser(this.repo);

  @override
  Future<Either<Failure, User>> call(String id) => repo.getUser(id);
}
