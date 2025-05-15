abstract class Failure {
  final String? message;

  Failure({required this.message});
}

// General failures
class ServerFailure extends Failure {
  ServerFailure(String s, {String? message}) : super(message: message);
}

class CacheFailure extends Failure {
  CacheFailure({String? message}) : super(message: message);
}

// Specific failures (you can add more as needed)
class UnauthorizedFailure extends ServerFailure {
  UnauthorizedFailure({String? message})
      : super('Unauthorized', message: message); // Added ''
}

class NotFoundFailure extends ServerFailure {
  NotFoundFailure({String? message})
      : super('Not Found', message: message); // Added ''
}

class NetworkFailure extends Failure {
  NetworkFailure({String? message}) : super(message: message);
}

// Example of a more specific cache failure
class EmptyCacheFailure extends CacheFailure {
  EmptyCacheFailure({String? message}) : super(message: message);
}

// Add more specific failures as needed, e.g.,
class InvalidInputFailure extends Failure {
  InvalidInputFailure({String? message}) : super(message: message);
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure({String? message}) : super(message: message);
}

class QuestExpiredFailure extends Failure {
  QuestExpiredFailure({String? message}) : super(message: message);
}

class LocationPermissionDeniedFailure extends Failure {
  LocationPermissionDeniedFailure({String? message}) : super(message: message);
}

class CameraPermissionDeniedFailure extends Failure {
  CameraPermissionDeniedFailure({String? message}) : super(message: message);
}
