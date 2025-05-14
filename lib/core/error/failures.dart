abstract class Failure {
  final String? message;

  const Failure([this.message]);
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([String? message]) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String? message]) : super(message);
}

// Specific failures (you can add more as needed)
class UnauthorizedFailure extends ServerFailure {
  const UnauthorizedFailure([String? message]) : super(message);
}

class NotFoundFailure extends ServerFailure {
  const NotFoundFailure([String? message]) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([String? message]) : super(message);
}

// Example of a more specific cache failure
class EmptyCacheFailure extends CacheFailure {
  const EmptyCacheFailure([String? message]) : super(message);
}

// Add more specific failures as needed, e.g.,
class InvalidInputFailure extends Failure {
  const InvalidInputFailure([String? message]) : super(message);
}

class QuestExpiredFailure extends Failure {
  const QuestExpiredFailure([String? message]) : super(message);
}

class LocationPermissionDeniedFailure extends Failure {
  const LocationPermissionDeniedFailure([String? message]) : super(message);
}

class CameraPermissionDeniedFailure extends Failure {
  const CameraPermissionDeniedFailure([String? message]) : super(message);
}
