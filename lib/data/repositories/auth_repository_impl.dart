import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, User>> signUp(
      String username, String email, String password, String faculty) async {
    try {
      final userModel =
          await _remoteDataSource.signUp(username, email, password, faculty);
      return Right(userModel.toDomain());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString())); // Improve error handling
    }
  }

  @override
  Future<Either<Failure, User>> signIn(String email, String password) async {
    try {
      final userModel = await _remoteDataSource.signIn(email, password);
      return Right(userModel.toDomain());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString())); // Improve error handling
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString())); // Improve error handling
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();
      return Right(userModel?.toDomain());
    } catch (e) {
      return Left(ServerFailure(e.toString())); // Improve error handling
    }
  }
}
