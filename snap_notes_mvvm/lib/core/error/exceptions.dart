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

  @override
  String toString() => message;
}

class LocalException implements Exception {
  final String message;
  LocalException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}

class OAuthException implements Exception {
  final String message;
  OAuthException(this.message);

  @override
  String toString() => message;
}
