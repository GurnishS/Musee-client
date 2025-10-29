import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/plan.dart';
import '../repository/admin_plans_repository.dart';

class UpdatePlanParams {
  final String id;
  final String? name;
  final double? price;
  final String? currency;
  final String? billingCycle;
  final Map<String, dynamic>? features;
  final int? maxDevices;
  final bool? isActive;
  UpdatePlanParams({
    required this.id,
    this.name,
    this.price,
    this.currency,
    this.billingCycle,
    this.features,
    this.maxDevices,
    this.isActive,
  });
}

class UpdatePlan implements UseCase<Plan, UpdatePlanParams> {
  final AdminPlansRepository repo;
  UpdatePlan(this.repo);

  @override
  Future<Either<Failure, Plan>> call(UpdatePlanParams params) async {
    return repo.updatePlan(
      params.id,
      name: params.name,
      price: params.price,
      currency: params.currency,
      billingCycle: params.billingCycle,
      features: params.features,
      maxDevices: params.maxDevices,
      isActive: params.isActive,
    );
  }
}
