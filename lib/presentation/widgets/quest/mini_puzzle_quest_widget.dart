import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart'
    as q; // Alias to avoid conflict

// Assuming these are defined in your project:
import 'package:final_project/domain/usecases/submit_quest_answer_usecase.dart'; // Import Use Case and Params
import 'package:final_project/core/error/failures.dart'; // Import Failure
import 'package:dartz/dartz.dart'; // Import Either
import 'package:final_project/presentation/providers/quest_provider.dart'; // Import providers
import 'package:final_project/domain/services/quest_submission_service.dart'; // Import SubmissionResult

import 'package:go_router/go_router.dart'; // For navigation
import '../../../core/constants/app_constants.dart'; // For routes
import '../../providers/auth_provider.dart'; // Assuming AuthProvider for user ID

// Import the Riverpod provider for SubmitMiniPuzzleAnswerUseCase
import '../../../core/di/providers.dart';

// ========================================================================
// MINI PUZZLE QUEST WIDGET (PLACEHOLDER)
// Displays a mini-puzzle and handles submission.
// ========================================================================
class MiniPuzzleQuestWidget extends ConsumerStatefulWidget {
  // Assuming q.Quest entity has properties for the puzzle:
  // String? puzzleDescription;
  // String? puzzleData; // e.g., JSON string describing the puzzle layout/rules
  final q.Quest quest;

  const MiniPuzzleQuestWidget({super.key, required this.quest});

  @override
  ConsumerState<MiniPuzzleQuestWidget> createState() =>
      _MiniPuzzleQuestWidgetState();
}

class _MiniPuzzleQuestWidgetState extends ConsumerState<MiniPuzzleQuestWidget> {
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submitMiniPuzzleUseCase =
        ref.read(submitMiniPuzzleAnswerUseCaseProvider);

    final puzzleDescription =
        widget.quest.question; // Using 'question' field for description
    // final puzzleData = widget.quest.puzzleData; // Assuming a specific field for puzzle data

    if (puzzleDescription == null /* || puzzleData == null */) {
      return const Center(child: Text('Invalid mini-puzzle quest data.'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mini-Puzzle:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(puzzleDescription), // Display puzzle description/instructions
          const SizedBox(height: 16),

          TextField(
            controller: _answerController,
            decoration: const InputDecoration(
              labelText: 'Your Answer',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: ElevatedButton(
              onPressed: _isSubmitting || _answerController.text.trim().isEmpty
                  ? null
                  : () {
                      _handleSubmit(context, ref, submitMiniPuzzleUseCase,
                          _answerController.text.trim());
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3),
                    )
                  : const Text('Submit Answer'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    SubmitQuestAnswerUseCase<SubmitMiniPuzzleAnswerParams>
        submitMiniPuzzleUseCase,
    String submittedAnswer,
  ) async {
    setState(() {
      _isSubmitting = true;
    });

    final userId = ref.read(authProvider).user?.id;

    if (userId == null) {
      _showError(context,
          const Failure(message: 'User not logged in. Cannot submit.'));
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final params = SubmitMiniPuzzleAnswerParams(
      questId: widget.quest.id ?? '',
      answer: submittedAnswer,
      userId: userId,
    );

    final result = await submitMiniPuzzleUseCase(params);

    result.fold(
      (failure) {
        _showError(context, failure);
      },
      (submissionResult) {
        _showSuccess(context);
        GoRouter.of(context).go(AppConstants.questResultRoute, extra: {
          'isSuccessful': submissionResult.isSuccessful,
          'pointsEarned': submissionResult.pointsEarned,
          'feedbackMessage': submissionResult.feedbackMessage,
          'newBadges': submissionResult.newBadges,
        });
      },
    );

    setState(() {
      _isSubmitting = false;
    });
  }

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
      const SnackBar(content: Text('Puzzle answer submitted!')),
    );
    setState(() {
      _answerController.clear();
    });
  }
}
