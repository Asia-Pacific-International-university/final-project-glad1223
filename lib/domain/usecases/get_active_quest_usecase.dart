// lib/domain/usecases/get_active_quest_usecase.dart
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:final_project/core/error/failures.dart';

// Assuming your NoParamFutureUseCase is defined as:
// abstract class NoParamFutureUseCase<T> {
//   Future<T> call(); // The T here is the direct success type or the Either itself
// }
// For consistency with how ParamFutureUseCase is defined (returning Either),
// let's adjust NoParamFutureUseCase if needed, or how GetActiveQuestUseCase implements it.

// Your current abstract class (from the snippet):
abstract class NoParamFutureUseCase<T> {
  Future<T> call();
}

// GetActiveQuestUseCase is trying to implement NoParamFutureUseCase<Either<Failure, Quest>>
// This means its call() method should return Future<Either<Failure, Quest>>.

class GetActiveQuestUseCase
    implements NoParamFutureUseCase<Either<Failure, Quest>> {
  // Return type of call() is Future<Either<Failure, Quest>>
  final QuestRepository _questRepository;

  GetActiveQuestUseCase({required QuestRepository questRepository})
      : _questRepository = questRepository;

  @override
  Future<Either<Failure, Quest>> call() async {
    // Matches the interface
    // _questRepository.getActiveQuest() returns Future<Either<Failure, Quest?>>
    final eitherResult = await _questRepository.getActiveQuest();

    // Use fold to handle the Either<Failure, Quest?>
    return eitherResult.fold(
      (failure) {
        // If _questRepository.getActiveQuest() returned a Left(failure)
        return Left(failure);
      },
      (questOrNull) {
        // If _questRepository.getActiveQuest() returned a Right(questOrNull)
        if (questOrNull == null) {
          // If the quest is null, we treat it as a NotFoundFailure as per your original logic.
          // This transforms Either<Failure, Quest?> into Either<Failure, Quest>
          // where a null Quest on success becomes a specific Failure.
          return Left(NotFoundFailure(message: 'No active quest found.'));
        } else {
          // If questOrNull is not null, then it's a valid Quest.
          return Right(questOrNull);
        }
      },
    );
  }
}

// Ensure NotFoundFailure is defined in your failures.dart, e.g.:
// class NotFoundFailure extends Failure {
//   NotFoundFailure({required String message}) : super(message);
// }
