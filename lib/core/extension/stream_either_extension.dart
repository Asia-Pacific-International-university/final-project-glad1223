// lib/core/extensions/stream_either_extension.dart

import 'package:dartz/dartz.dart';
import 'package:rxdart/rxdart.dart'; // For onErrorReturnWith
import '../error/failures.dart'; // Assuming your Failure classes are defined here

/// An extension on Stream to easily convert it into a Stream of Either<Failure, T>.
///
/// This simplifies error handling within stream pipelines by mapping errors
/// to Left(Failure) events, allowing the stream to continue emitting data
/// or error states in a consistent Either wrapper.
extension StreamEitherExtension<T> on Stream<T> {
  /// Transforms a [Stream<T>] into a [Stream<Either<Failure, T>>].
  ///
  /// On successful data emission, it wraps the data in [Right<Failure, T>].
  /// On error emission, it catches the error and uses the provided [errorMapper]
  /// to convert it into a [Failure], which is then wrapped in [Left<Failure, T>].
  ///
  /// [errorMapper]: A function that takes the dynamic error and its stack trace
  /// and returns a [Failure] instance.
  Stream<Either<Failure, T>> toEitherStream(
      Failure Function(dynamic error, StackTrace stackTrace) errorMapper) {
    return this.map<Either<Failure, T>>((data) {
      // Explicitly type Right to help Dart's inference for the overall stream type
      return Right<Failure, T>(data);
    }).onErrorReturnWith((error, stackTrace) {
      // Explicitly type Left to help Dart's inference
      return Left<Failure, T>(errorMapper(error, stackTrace));
    });
  }
}
