import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:musee/core/secrets/app_secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../models/plan_model.dart';

abstract interface class AdminPlansRemoteDataSource {
  Future<List<PlanModel>> listPlans();
  Future<PlanModel> getPlan(String id);
  Future<PlanModel> createPlan({
    required String name,
    required double price,
    String currency,
    String billingCycle,
    Map<String, dynamic>? features,
    int? maxDevices,
    bool? isActive,
  });
  Future<PlanModel> updatePlan(
    String id, {
    String? name,
    double? price,
    String? currency,
    String? billingCycle,
    Map<String, dynamic>? features,
    int? maxDevices,
    bool? isActive,
  });
  Future<void> deletePlan(String id);
}

class AdminPlansRemoteDataSourceImpl implements AdminPlansRemoteDataSource {
  final dio.Dio _dio;
  final supa.SupabaseClient supabase;
  final String basePath;

  AdminPlansRemoteDataSourceImpl(this._dio, this.supabase)
    : basePath = '${AppSecrets.backendUrl}/api/admin/plans';

  Map<String, String> _authHeader() {
    final token = supabase.auth.currentSession?.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Missing Supabase access token for admin API request');
    }
    return {'Authorization': 'Bearer $token'};
  }

  @override
  Future<List<PlanModel>> listPlans() async {
    final res = await _dio.get(
      basePath,
      options: dio.Options(headers: _authHeader()),
    );
    if (kDebugMode) debugPrint('listPlans: ${res.data}');
    final data = res.data as Map<String, dynamic>;
    final list = (data['items'] ?? data['data'] ?? []) as List;
    return list
        .map((e) => PlanModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<PlanModel> getPlan(String id) async {
    final res = await _dio.get(
      '$basePath/$id',
      options: dio.Options(headers: _authHeader()),
    );
    return PlanModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  @override
  Future<PlanModel> createPlan({
    required String name,
    required double price,
    String currency = 'INR',
    String billingCycle = 'monthly',
    Map<String, dynamic>? features,
    int? maxDevices,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'price': price,
      'currency': currency,
      'billing_cycle': billingCycle,
      if (features != null) 'features': features,
      if (maxDevices != null) 'max_devices': maxDevices,
      if (isActive != null) 'is_active': isActive,
    };
    final res = await _dio.post(
      basePath,
      data: body,
      options: dio.Options(headers: _authHeader()),
    );
    return PlanModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  @override
  Future<PlanModel> updatePlan(
    String id, {
    String? name,
    double? price,
    String? currency,
    String? billingCycle,
    Map<String, dynamic>? features,
    int? maxDevices,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
      if (billingCycle != null) 'billing_cycle': billingCycle,
      if (features != null) 'features': features,
      if (maxDevices != null) 'max_devices': maxDevices,
      if (isActive != null) 'is_active': isActive,
    };
    final res = await _dio.patch(
      '$basePath/$id',
      data: body,
      options: dio.Options(headers: _authHeader()),
    );
    return PlanModel.fromJson(Map<String, dynamic>.from(res.data));
  }

  @override
  Future<void> deletePlan(String id) async {
    await _dio.delete(
      '$basePath/$id',
      options: dio.Options(headers: _authHeader()),
    );
  }
}
