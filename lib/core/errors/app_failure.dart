class AppFailure implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const AppFailure(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message, {super.statusCode, super.originalError});
}

class AuthFailure extends AppFailure {
  const AuthFailure(super.message, {super.statusCode, super.originalError});
}

class ServerFailure extends AppFailure {
  const ServerFailure(super.message, {super.statusCode, super.originalError});
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.statusCode, super.originalError});
}
