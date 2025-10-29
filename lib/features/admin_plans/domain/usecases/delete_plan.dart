import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../repository/admin_plans_repository.dart';

class DeletePlan implements UseCase<void, String> {
  final AdminPlansRepository repo;
  DeletePlan(this.repo);

  @override
  Future<Either<Failure, void>> call(String id) async {
    return repo.deletePlan(id);
  }
}
