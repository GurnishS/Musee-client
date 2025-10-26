import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import 'package:musee/features/admin_users/domain/repository/admin_repository.dart';

class DeleteUser implements UseCase<void, String> {
  final AdminRepository repo;
  DeleteUser(this.repo);

  @override
  Future<Either<Failure, void>> call(String id) => repo.deleteUser(id);
}
