import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import 'package:musee/core/common/entities/user.dart';
import 'package:musee/features/auth/domain/repository/auth_repository.dart';
import 'package:musee/features/auth/domain/usecases/auth_validation.dart';
import 'package:fpdart/fpdart.dart';

class UserSignIn implements UseCase<User, UserSignInParams> {
  final AuthRepository authRepository;
  const UserSignIn(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserSignInParams params) async {
    // Validate inputs before making the request
    final emailError = AuthValidation.validateEmail(params.email);
    if (emailError != null) {
      return Left(Failure(emailError));
    }

    final passwordError = AuthValidation.validatePassword(params.password);
    if (passwordError != null) {
      return Left(Failure(passwordError));
    }

    return await authRepository.signInWithEmailPassword(
      email: params.normalizedEmail,
      password: params.password,
    );
  }
}

class UserSignInParams {
  final String email;
  final String password;

  UserSignInParams({required this.email, required this.password});

  /// Returns normalized email
  String get normalizedEmail => AuthValidation.normalizeEmail(email);

  /// Returns a copy with normalized email
  UserSignInParams get normalized =>
      UserSignInParams(email: normalizedEmail, password: password);
}
