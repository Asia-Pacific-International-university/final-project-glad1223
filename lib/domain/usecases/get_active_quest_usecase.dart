import 'package:final_project/core/usecases/usecase.dart'; // Assuming NoParamFutureUseCase is defined here
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';
import 'package:dartz/dartz.dart'; // Import dartz
import 'package:final_project/core/error/failures.dart'; // Import your Failure class

class GetActiveQuestUseCase
    implements NoParamFutureUseCase<Either<Failure, Quest>> {
  // Change return type
  final QuestRepository _questRepository;

  GetActiveQuestUseCase({required QuestRepository questRepository})
      : _questRepository = questRepository;

  @override
  Future<Either<Failure, Quest>> call() async {
    try {
      final Quest? quest = await _questRepository.getActiveQuest();
      if (quest == null) {
        return Left(NotFoundFailure(
            message: 'No active quest found.')); // Handle null from repository
      }
      return Right(quest);
    } on Failure catch (e) {
      return Left(e); // Return the Failure directly
    } catch (e) {
      return Left(UnexpectedFailure(
          message: 'Unexpected error: $e')); // Catch other errors
    }
  }
}
