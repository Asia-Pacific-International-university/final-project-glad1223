//import 'package:final_project/core/usecases/usecase.dart';
import 'package:final_project/domain/repositories/quest_repository.dart';
//import 'package:final_project/domain/repositories/user_repositories.dart';
import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'dart:async';

// *** 1. Define the UseCase interface (if you haven't already) ***
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// *** 2. Define ParamFutureUseCase (VERY IMPORTANT) ***
abstract class ParamFutureUseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// *** 3. Define NoParamFutureUseCase (if needed) ***
abstract class NoParamFutureUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

// *** 4. Define ProcessQuestSubmissionUseCase ***
class ProcessQuestSubmissionUseCase
    implements ParamFutureUseCase<void, ProcessQuestSubmissionParams> {
  // Corrected implements clause
  final QuestRepository _questRepository;
  final UserRepositories _userRepository;

  ProcessQuestSubmissionUseCase(
      {required QuestRepository questRepository,
      required UserRepositories userRepository})
      : _questRepository = questRepository,
        _userRepository = userRepository;

  @override
  Future<Either<Failure, void>> call(
      ProcessQuestSubmissionParams params) async {
    // 1. Submit the answer to the quest repository
    final submissionResult = await _questRepository.submitTriviaAnswer(
        params.questId, params.answer);

    // 2. Handle the result of the submission and potential points update
    return await submissionResult.fold<Future<Either<Failure, void>>>(
      // Explicit Future
      (failure) {
        return Future<Either<Failure, void>>.value(Left(failure));
      },
      (success) async {
        try {
          final updateResult = await _userRepository.addPoints(
              params.userId, params.pointsAwarded);
          return updateResult;
        } on Failure catch (failure) {
          return Future<Either<Failure, void>>.value(Left(failure));
        } catch (e) {
          return Future<Either<Failure, void>>.value(
              Left(ServerFailure('Failed to update points: $e')));
        }
      },
    );
  }
}

// *** 5. Define ProcessQuestSubmissionParams ***
class ProcessQuestSubmissionParams {
  final String questId;
  final String answer;
  final String userId;
  final int pointsAwarded;

  ProcessQuestSubmissionParams({
    required this.questId,
    required this.answer,
    required this.userId,
    required this.pointsAwarded,
  });
}

// *** 6. Updated UserRepositories interface ***
abstract class UserRepositories {
  // ... other methods ...
  Future<Either<Failure, void>> addPoints(String userId, int points);
}
