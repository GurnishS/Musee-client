import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/plan.dart';
import '../repository/admin_plans_repository.dart';

class ListPlans implements UseCase<List<Plan>, NoParams> {
  final AdminPlansRepository repo;
  ListPlans(this.repo);

  @override
  Future<Either<Failure, List<Plan>>> call(NoParams params) async {
    return repo.listPlans();
  }
}
