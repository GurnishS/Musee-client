import 'package:fpdart/fpdart.dart';
import 'package:musee/core/common/entities/user.dart';
import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import 'package:musee/features/admin_users/domain/repository/admin_repository.dart';

class CreateUser implements UseCase<User, CreateUserParams> {
  final AdminRepository repo;
  CreateUser(this.repo);

  @override
  Future<Either<Failure, User>> call(CreateUserParams params) {
    return repo.createUser(
      name: params.name,
      email: params.email,
      subscriptionType: params.subscriptionType,
      planId: params.planId,
      avatarBytes: params.avatarBytes,
      avatarFilename: params.avatarFilename,
    );
  }
}

class CreateUserParams {
  final String name;
  final String email;
  final SubscriptionType subscriptionType;
  final String? planId;
  final List<int>? avatarBytes;
  final String? avatarFilename;

  const CreateUserParams({
    required this.name,
    required this.email,
    this.subscriptionType = SubscriptionType.free,
    this.planId,
    this.avatarBytes,
    this.avatarFilename,
  });
}
