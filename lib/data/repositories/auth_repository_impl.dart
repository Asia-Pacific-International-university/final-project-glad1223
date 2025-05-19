// *** lib/data/repositories/auth_repository_impl.dart ***
import 'package:dartz/dartz.dart';
import '../../../core/constants/app_constants.dart'; // Import role enum
import '../../../core/error/exceptions.dart'; // Assuming custom exceptions
import '../../../core/error/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
// import '../datasources/local/auth_local_datasource.dart'; // If you have a local source
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  // final AuthLocalDataSource localDataSource; // If you have one

  AuthRepositoryImpl(
      {required this.remoteDataSource /*, this.localDataSource*/});

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String? facultyId, // Made nullable to align with data source
    required UserRole role, // Accept the role
  }) async {
    try {
      final userModel = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        facultyId: facultyId,
        role: role, // Pass role to data source
      );
      // Optionally cache user locally
      // await localDataSource.cacheUser(userModel);
      return Right(userModel); // UserModel extends User, so this is fine
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      // Catch any other unexpected errors
      return Left(OtherFailure(e.toString())); // Or a generic Failure
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Optionally cache user locally
      // await localDataSource.cacheUser(userModel);
      return Right(userModel); // UserModel extends User
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(OtherFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(OtherFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel); // UserModel can be null, so User? works
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(OtherFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserFaculty(
      {required String userId, required String facultyId}) async {
    try {
      final userModel = await remoteDataSource.updateUserFaculty(
          userId: userId, facultyId: facultyId);
      // Update local cache if you have one
      // await localDataSource.cacheUser(userModel);
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(OtherFailure(e.toString()));
    }
  }
}
