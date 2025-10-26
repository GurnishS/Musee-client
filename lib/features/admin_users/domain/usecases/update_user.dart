import 'package:fpdart/fpdart.dart';
import 'package:musee/core/common/entities/user.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import 'package:musee/features/admin_users/domain/repository/admin_repository.dart';

class UpdateUser implements UseCase<User, UpdateUserParams> {
  final AdminRepository repo;
  UpdateUser(this.repo);

  @override
  Future<Either<Failure, User>> call(UpdateUserParams params) {
    return repo.updateUser(
      id: params.id,
      name: params.name,
      email: params.email,
      subscriptionType: params.subscriptionType,
      userType: params.userType,
      planId: params.planId,
      avatarBytes: params.avatarBytes,
      avatarFilename: params.avatarFilename,
    );
  }
}

class UpdateUserParams {
  final String id;
  final String? name;
  final String? email;
  final SubscriptionType? subscriptionType;
  final UserType? userType;
  final String? planId;
  final List<int>? avatarBytes;
  final String? avatarFilename;

  const UpdateUserParams({
    required this.id,
    this.name,
    this.email,
    this.subscriptionType,
    this.userType,
    this.planId,
    this.avatarBytes,
    this.avatarFilename,
  });
}
