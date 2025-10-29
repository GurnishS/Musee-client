import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/plan.dart';
import '../repository/admin_plans_repository.dart';

class GetPlan implements UseCase<Plan, String> {
  final AdminPlansRepository repo;
  GetPlan(this.repo);

  @override
  Future<Either<Failure, Plan>> call(String id) async {
    return repo.getPlan(id);
  }
}
