class Failure {
  final String message;
  Failure([this.message = 'An unexpected error has occured']);
}

class EmailVerificationFailure extends Failure {
  final String email;
  EmailVerificationFailure(this.email)
    : super('Email verification required for $email');
}
