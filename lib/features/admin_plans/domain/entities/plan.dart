class Plan {
  final String id; // plan_id
  final String name;
  final double price;
  final String currency; // default INR
  final String billingCycle; // monthly|yearly|lifetime
  final Map<String, dynamic> features; // default {}
  final int maxDevices; // >=1 default 1
  final bool isActive; // default true
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.billingCycle,
    this.features = const {},
    this.maxDevices = 1,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });
}
