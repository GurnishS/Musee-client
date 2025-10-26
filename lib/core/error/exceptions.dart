class ServerException implements Exception {
  final String message;

  const ServerException(this.message);
}

class ServerExceptionWithStatusCode extends ServerException {
  final int statusCode;

  const ServerExceptionWithStatusCode(this.statusCode, String message)
      : super(message);
}

class EmailVerificationRequiredException implements Exception {
  final String email;
  const EmailVerificationRequiredException(this.email);
}
