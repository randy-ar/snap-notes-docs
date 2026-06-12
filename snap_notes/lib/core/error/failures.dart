import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class LocalFailure extends Failure {
  const LocalFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message);
}

class OAuthFailure extends Failure {
  const OAuthFailure(super.message);
}

class ValidationFailure extends Failure {
  final Map<String, String>? errors;
  const ValidationFailure(super.message, {this.errors});
}
