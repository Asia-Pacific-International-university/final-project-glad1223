import 'package:dartz/dartz.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/error/failures.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart'; // Import the abstract remote data source
import '../../data/models/user_model.dart'; // Import UserModel

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource
      _remoteDataSource; // Dependency on the remote data source

  AuthRepositoryImpl({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserModel>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    required String? facultyId,
    required UserRole role,
  }) async {
    try {
      final userModel = await _remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        facultyId: facultyId,
        role: role,
      );
      return Right(userModel);
    } on Exception catch (e) {
      return Left(ServerFailure('Failed to sign up: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userModel);
    } on Exception catch (e) {
      return Left(ServerFailure('Failed to sign in: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on Exception catch (e) {
      return Left(ServerFailure('Failed to sign out: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      return Right(userModel);
    } on Exception catch (e) {
      return Left(ServerFailure('Failed to get current user: ${e.toString()}'));
    }
  }
}
