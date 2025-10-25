import 'package:musee/core/error/failures.dart';
import 'package:musee/core/usecase/usecase.dart';
import 'package:musee/features/auth/domain/repository/auth_repository.dart';
import 'package:musee/features/auth/domain/usecases/auth_validation.dart';
import 'package:fpdart/fpdart.dart';

class ResendEmailVerification
    implements UseCase<void, ResendEmailVerificationParams> {
  final AuthRepository authRepository;
  const ResendEmailVerification(this.authRepository);

  @override
  Future<Either<Failure, void>> call(
    ResendEmailVerificationParams params,
  ) async {
    // Validate email before making the request
    final emailError = AuthValidation.validateEmail(params.email);
    if (emailError != null) {
      return Left(Failure(emailError));
    }

    return await authRepository.resendEmailVerification(
      email: params.normalizedEmail,
    );
  }
}

class ResendEmailVerificationParams {
  final String email;

  ResendEmailVerificationParams({required this.email});

  /// Returns normalized email
  String get normalizedEmail => AuthValidation.normalizeEmail(email);

  /// Returns a copy with normalized email
  ResendEmailVerificationParams get normalized =>
      ResendEmailVerificationParams(email: normalizedEmail);
}
