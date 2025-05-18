// lib/domain/usecases/update_faculty_usecase.dart
// Add new use case for updating faculty
class UpdateUserFacultyParams extends Equatable {
  final String userId;
  final String facultyId;

  const UpdateUserFacultyParams(
      {required this.userId, required this.facultyId});

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
        userId: params.userId, facultyId: params.facultyId);
  }
}
