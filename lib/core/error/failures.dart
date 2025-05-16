abstract class Failure {
  final String message;

  const Failure({required this.message});
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message: message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

// Specific failures (you can add more as needed)
class UnauthorizedFailure extends ServerFailure {
  const UnauthorizedFailure({String message = 'Unauthorized'}) : super(message);
}

class NotFoundFailure extends ServerFailure {
  const NotFoundFailure({String message = 'Not Found'}) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

// Example of a more specific cache failure
class EmptyCacheFailure extends CacheFailure {
  const EmptyCacheFailure({String message = 'Cache is empty'})
      : super(message: message);
}

// Add more specific failures as needed, e.g.,
class InvalidInputFailure extends Failure {
  const InvalidInputFailure({required String message})
      : super(message: message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({String message = 'An unexpected error occurred'})
      : super(message: message);
}

class QuestExpiredFailure extends Failure {
  const QuestExpiredFailure({String message = 'This quest has expired'})
      : super(message: message);
}

class LocationPermissionDeniedFailure extends Failure {
  const LocationPermissionDeniedFailure(
      {String message = 'Location permission denied'})
      : super(message: message);
}

class CameraPermissionDeniedFailure extends Failure {
  const CameraPermissionDeniedFailure(
      {String message = 'Camera permission denied'})
      : super(message: message);
}
