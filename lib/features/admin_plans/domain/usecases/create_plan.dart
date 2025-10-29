import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import '../entities/plan.dart';
import '../repository/admin_plans_repository.dart';

class CreatePlanParams {
  final String name;
  final double price;
  final String currency;
  final String billingCycle;
  final Map<String, dynamic>? features;
  final int? maxDevices;
  final bool? isActive;
  CreatePlanParams({
    required this.name,
    required this.price,
    this.currency = 'INR',
    this.billingCycle = 'monthly',
    this.features,
    this.maxDevices,
    this.isActive,
  });
}

class CreatePlan implements UseCase<Plan, CreatePlanParams> {
  final AdminPlansRepository repo;
  CreatePlan(this.repo);

  @override
  Future<Either<Failure, Plan>> call(CreatePlanParams params) async {
    return repo.createPlan(
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
