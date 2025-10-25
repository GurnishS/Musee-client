import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import 'package:musee/core/common/entities/user.dart';
import 'package:musee/features/auth/domain/repository/auth_repository.dart';
import 'package:musee/features/auth/domain/usecases/auth_validation.dart';
import 'package:fpdart/fpdart.dart';

class UserSignUp implements UseCase<User, UserSignUpParams> {
  final AuthRepository authRepository;
  const UserSignUp(this.authRepository);

  @override
  Future<Either<Failure, User>> call(UserSignUpParams params) async {
    // Validate inputs before making the request
    final emailError = AuthValidation.validateEmail(params.email);
    if (emailError != null) {
      return Left(Failure(emailError));
    }

    final passwordError = AuthValidation.validatePassword(params.password);
    if (passwordError != null) {
      return Left(Failure(passwordError));
    }

    final nameError = AuthValidation.validateName(params.name);
    if (nameError != null) {
      return Left(Failure(nameError));
    }

    return await authRepository.signUpWithEmailPassword(
      name: params.normalizedName,
      email: params.normalizedEmail,
      password: params.password,
    );
  }
}

class UserSignUpParams {
  final String name;
  final String email;
  final String password;

  UserSignUpParams({
    required this.name,
    required this.email,
    required this.password,
  });

  /// Returns normalized name
  String get normalizedName => AuthValidation.normalizeName(name);

  /// Returns normalized email
  String get normalizedEmail => AuthValidation.normalizeEmail(email);

  /// Returns a copy with normalized values
  UserSignUpParams get normalized => UserSignUpParams(
    name: normalizedName,
    email: normalizedEmail,
    password: password,
  );
}
