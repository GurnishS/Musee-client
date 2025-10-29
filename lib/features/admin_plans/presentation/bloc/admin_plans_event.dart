part of 'admin_plans_bloc.dart';

abstract class AdminPlansEvent {}

class LoadPlans extends AdminPlansEvent {}

class CreatePlanEvent extends AdminPlansEvent {
  final String name;
  final double price;
  final String? currency;
  final String? billingCycle;
  final Map<String, dynamic>? features;
  final int? maxDevices;
  final bool? isActive;
  CreatePlanEvent({
    required this.name,
    required this.price,
    this.currency,
    this.billingCycle,
    this.features,
    this.maxDevices,
    this.isActive,
  });
}

class UpdatePlanEvent extends AdminPlansEvent {
  final String id;
  final String? name;
  final double? price;
  final String? currency;
  final String? billingCycle;
  final Map<String, dynamic>? features;
  final int? maxDevices;
  final bool? isActive;
  UpdatePlanEvent({
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

class DeletePlanEvent extends AdminPlansEvent {
  final String id;
  DeletePlanEvent(this.id);
}
