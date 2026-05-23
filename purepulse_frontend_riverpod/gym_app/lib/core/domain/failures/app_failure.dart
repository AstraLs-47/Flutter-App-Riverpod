/// Base sealed class for all application failures.
/// Use these in UseCases and Repository contracts instead of raw exceptions.
sealed class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Failure due to network/connectivity issues (SocketException, timeout).
class NetworkFailure extends AppFailure {
  const NetworkFailure([String message = 'No internet connection'])
      : super(message);
}

/// Failure when reading/writing the local SQLite cache.
class CacheFailure extends AppFailure {
  const CacheFailure([String message = 'Local cache error']) : super(message);
}

/// Failure caused by invalid user input or business rule violation.
class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

/// Failure caused by authentication errors (401, expired token, bad credentials).
class AuthFailure extends AppFailure {
  const AuthFailure([String message = 'Authentication failed']) : super(message);
}

/// Failure returned by the backend server (4xx / 5xx not covered by others).
class ServerFailure extends AppFailure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  String toString() => 'ServerFailure($statusCode): $message';
}

/// Maps an arbitrary exception to the closest [AppFailure] subtype.
AppFailure mapExceptionToFailure(Object error) {
  if (error is AppFailure) return error;
  final msg = error.toString();
  if (msg.contains('401') || msg.contains('Unauthorized') || msg.contains('Authentication')) {
    return const AuthFailure();
  }
  if (msg.contains('503') || msg.contains('No internet') || msg.contains('SocketException')) {
    return const NetworkFailure();
  }
  return ServerFailure(msg);
}
