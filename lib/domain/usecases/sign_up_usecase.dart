// lib/domain/usecases/sign_up_usecase.dart
// This file will also contain UpdateUserFacultyUseCase
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/error/failures.dart'; // Ensure failures are imported
import '../../../core/constants/app_constants.dart'; // Ensure role enum is imported
import '../entities/user.dart'; // Ensure User entity is imported
import '../repositories/auth_repositories.dart'; // Ensure repository is imported
import 'usecase.dart'; // Your base UseCase definition

// SignUp Use Case
class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String username;
  final String? facultyId; // Made nullable to align with repository
  final UserRole role;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.username,
    this.facultyId, // Made optional
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, username, facultyId, role];
}

class SignUpUseCase implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) async {
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      username: params.username,
      facultyId: params.facultyId,
      role: params.role,
    );
  }
}

// Update User Faculty Use Case
class UpdateUserFacultyParams extends Equatable {
  final String userId;
  final String facultyId;

  const UpdateUserFacultyParams({
    required this.userId,
    required this.facultyId,
  });

  @override
  List<Object?> get props => [userId, facultyId];
}

class UpdateUserFacultyUseCase
    implements UseCase<User, UpdateUserFacultyParams> {
  final AuthRepository repository;

  UpdateUserFacultyUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateUserFacultyParams params) async {
    return await repository.updateUserFaculty(
      userId: params.userId,
      facultyId: params.facultyId,
    );
  }
}
