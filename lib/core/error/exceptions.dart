/// Represents a general failure on the server side.
/// This could be for network issues, API errors, or unexpected server responses.
class ServerException implements Exception {
  final String message;

  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}

/// Represents an error related to user authentication.
/// This includes issues like invalid credentials, disabled accounts, etc.
class AuthenticationException implements Exception {
  final String message;

  AuthenticationException(this.message);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Specifically indicates that the email address provided is already in use.
/// This is a common error during user registration.
class EmailAlreadyInUseException implements Exception {
  final String message;

  EmailAlreadyInUseException(this.message);

  @override
  String toString() => 'EmailAlreadyInUseException: $message';
}

/// Represents a situation where no internet connection is available.
class NoInternetException implements Exception {
  final String message;

  NoInternetException(
      [this.message = 'No internet connection. Please check your network.']);

  @override
  String toString() => 'NoInternetException: $message';
}

/// Represents an error where a requested resource (e.g., user, document) is not found.
class NotFoundException implements Exception {
  final String message;

  NotFoundException([this.message = 'The requested resource was not found.']);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Represents an error due to invalid input data.
class InvalidInputException implements Exception {
  final String message;

  InvalidInputException(this.message);

  @override
  String toString() => 'InvalidInputException: $message';
}
