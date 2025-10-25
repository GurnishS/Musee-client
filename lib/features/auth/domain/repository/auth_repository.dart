import 'package:musee/core/error/failures.dart';
import 'package:musee/core/common/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> currentUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> resendEmailVerification({
    required String email,
  });
  Future<Either<Failure, void>> sendPasswordResetEmail({required String email});
}
