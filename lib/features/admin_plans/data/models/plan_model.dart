import '../../domain/entities/plan.dart';

class PlanModel extends Plan {
  const PlanModel({
    required super.id,
    required super.name,
    required super.price,
    required super.currency,
    required super.billingCycle,
    super.features = const {},
    super.maxDevices = 1,
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: (json['plan_id'] ?? json['id']).toString(),
      name: (json['name'] ?? '') as String,
      price: (json['price'] as num).toDouble(),
      currency: (json['currency'] ?? 'INR') as String,
      billingCycle: (json['billing_cycle'] ?? 'monthly') as String,
      features: Map<String, dynamic>.from(json['features'] as Map? ?? const {}),
      maxDevices: (json['max_devices'] as num?)?.toInt() ?? 1,
      isActive: (json['is_active'] as bool?) ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
