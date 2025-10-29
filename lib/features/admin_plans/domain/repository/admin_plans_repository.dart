import 'package:fpdart/fpdart.dart';
import '../entities/plan.dart';
import 'package:musee/core/error/failures.dart';

abstract interface class AdminPlansRepository {
  Future<Either<Failure, List<Plan>>> listPlans();
  Future<Either<Failure, Plan>> getPlan(String id);
  Future<Either<Failure, Plan>> createPlan({
    required String name,
    required double price,
    String currency,
    String billingCycle,
    Map<String, dynamic>? features,
    int? maxDevices,
    bool? isActive,
  });
  Future<Either<Failure, Plan>> updatePlan(
    String id, {
    String? name,
    double? price,
    String? currency,
    String? billingCycle,
    Map<String, dynamic>? features,
    int? maxDevices,
    bool? isActive,
  });
  Future<Either<Failure, void>> deletePlan(String id);
}
