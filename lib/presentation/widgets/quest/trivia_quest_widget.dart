import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart';
//import 'package:final_project/presentation/providers/quest_provider.dart';
//import 'package:final_project/domain/usecases/submit_quest_answer_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:final_project/core/error/failures.dart';

// 1. Define Parameters Class
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

class TriviaQuestWidget extends ConsumerWidget {
  final Quest quest;
  final TextEditingController _answerController = TextEditingController();

  TriviaQuestWidget({super.key, required this.quest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2. Access the UseCase
    final submitTriviaUseCase = ref.read(submitQuestAnswerUseCaseProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3. Safely Access Quest Data
          _buildQuestionText(),
          const SizedBox(height: 8),
          TextField(
            controller: _answerController,
            decoration: const InputDecoration(
              labelText: 'Your Answer',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _handleSubmit(
                context, ref, submitTriviaUseCase), // Corrected here
            child: const Text('Submit Answer'),
          ),
        ],
      ),
    );
  }

  // 4. Extract Question Display
  Widget _buildQuestionText() {
    if (quest.question != null) {
      return Text(
        'Question: ${quest.question}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      );
    }
    return const Text('Question: (No question data available)',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  // 5. Extract Submit Logic
  Future<void> _handleSubmit(BuildContext context, WidgetRef ref,
      SubmitQuestAnswerUseCase submitTriviaUseCase) async {
    // Added return type
    if (_answerController.text.trim().isNotEmpty) {
      final params = ProcessQuestSubmissionParams(
        questId: quest.id ?? '',
        answer: _answerController.text.trim(),
        userId: 'user_id', // Replace with actual user ID
        pointsAwarded: 10, // Replace with actual points
      );

      final result = await submitTriviaUseCase(params); // Await the result

      // Handle the result using fold. This is the correct way to handle Either.
      result.fold(
        (failure) {
          _showError(context, failure);
        },
        (success) {
          _showSuccess(context);
        },
      );
    } else {
      _showInputError(context);
    }
  }

  // 6. Extracted Error and Success Handlers
  void _showError(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${failure.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Answer submitted successfully!')),
    );
    _answerController.clear();
  }

  void _showInputError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter your answer.')),
    );
  }
}

// 7. (CRITICAL) Define the UseCase and Provider (if you haven't already)
//     These should be in their respective files (e.g., domain/usecases/submit_quest_answer_usecase.dart)
//
//     Example UseCase:
abstract class SubmitQuestAnswerUseCase
    extends UseCase<void, ProcessQuestSubmissionParams> {
  Future<Either<Failure, void>> call(ProcessQuestSubmissionParams params);
}

class SubmitQuestAnswerUseCaseImpl implements SubmitQuestAnswerUseCase {
  // Replace with your actual repository
  // final QuestRepository _questRepository;
  // SubmitQuestAnswerUseCaseImpl(this._questRepository);

  @override
  Future<Either<Failure, void>> call(
      ProcessQuestSubmissionParams params) async {
    // Simulate a successful submission. Replace this with your actual logic.
    // try {
    //   await _questRepository.submitAnswer(params.questId, params.answer, params.userId, params.pointsAwarded);
    //   return const Right(null);
    // } catch (e) {
    //   return Left(SomeSpecificFailure(message: e.toString())); // Create specific failure types
    // }
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    if (params.answer == "correct") {
      return const Right(null);
    } else {
      return Left(IncorrectAnswerFailure(
          message: "Incorrect Answer.  Please try again."));
    }
  }
}

//
//     Example Provider (in presentation/providers/quest_provider.dart)
final submitQuestAnswerUseCaseProvider =
    Provider<SubmitQuestAnswerUseCase>((ref) {
  // Replace with your repository implementation
  // final questRepository = ref.read(questRepositoryProvider);  // Get your repository
  return SubmitQuestAnswerUseCaseImpl(); // Pass the repository to the UseCase
});

// 8. (CRITICAL) Define Failure type
class IncorrectAnswerFailure extends Failure {
  IncorrectAnswerFailure({required String message}) : super(message: message);
}

// 9. (CRITICAL)  Define the UseCase Interface
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
