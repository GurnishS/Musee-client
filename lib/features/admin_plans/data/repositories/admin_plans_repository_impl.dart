import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:musee/core/error/failures.dart';
import '../../domain/entities/plan.dart';
import '../../domain/repository/admin_plans_repository.dart';
import '../datasources/admin_plans_remote_data_source.dart';

class AdminPlansRepositoryImpl implements AdminPlansRepository {
  final AdminPlansRemoteDataSource remote;
  AdminPlansRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<Plan>>> listPlans() async {
    try {
      final res = await remote.listPlans();
      return Right(res);
    } on DioException catch (e) {
      return Left(Failure(e.message ?? 'Failed to list plans'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Plan>> getPlan(String id) async {
    try {
      final res = await remote.getPlan(id);
      return Right(res);
    } on DioException catch (e) {
      return Left(Failure(e.message ?? 'Failed to get plan'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Plan>> createPlan({
    required String name,
    required double price,
    String currency = 'INR',
    String billingCycle = 'monthly',
    Map<String, dynamic>? features,
    int? maxDevices,
    bool? isActive,
  }) async {
    try {
      final res = await remote.createPlan(
        name: name,
        price: price,
        currency: currency,
        billingCycle: billingCycle,
        features: features,
        maxDevices: maxDevices,
        isActive: isActive,
      );
      return Right(res);
    } on DioException catch (e) {
      return Left(Failure(e.message ?? 'Failed to create plan'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Plan>> updatePlan(
    String id, {
    String? name,
    double? price,
    String? currency,
    String? billingCycle,
    Map<String, dynamic>? features,
    int? maxDevices,
    bool? isActive,
  }) async {
    try {
      final res = await remote.updatePlan(
        id,
        name: name,
        price: price,
        currency: currency,
        billingCycle: billingCycle,
        features: features,
        maxDevices: maxDevices,
        isActive: isActive,
      );
      return Right(res);
    } on DioException catch (e) {
      return Left(Failure(e.message ?? 'Failed to update plan'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlan(String id) async {
    try {
      await remote.deletePlan(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(e.message ?? 'Failed to delete plan'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
