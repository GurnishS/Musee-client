import 'package:musee/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract class UseCase<SuccessType, Params> {
  Future<Either<Failure, SuccessType>> call(Params params);
}

class NoParams {}
