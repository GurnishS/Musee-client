class ServerException implements Exception {
  final String message;

  const ServerException(this.message);
}

class EmailVerificationRequiredException implements Exception {
  final String email;
  const EmailVerificationRequiredException(this.email);
}
