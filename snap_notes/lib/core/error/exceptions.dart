class ServerException implements Exception {
  final String message;
  final Map<String, dynamic>? serverResponse;
  final int? statusCode;
  final StackTrace? stackTrace;

  ServerException(
    this.message, {
    this.serverResponse,
    this.statusCode,
    this.stackTrace,
  });
}

class LocalException implements Exception {
  final String message;
  LocalException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}

class OAuthException implements Exception {
  final String message;
  OAuthException(this.message);
}
