import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart' as q;
import 'package:final_project/domain/usecases/submit_quest_answer_usecase.dart';
import 'package:final_project/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:final_project/presentation/providers/quest_provider.dart';
import 'package:final_project/domain/services/quest_submission_service.dart';

import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

import '../../../core/di/providers.dart';

class MiniPuzzleQuestWidget extends ConsumerStatefulWidget {
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

    final puzzleDescription = widget.quest.question;

    if (puzzleDescription == null) {
      return Center(
        child: Text(
          'Invalid mini-puzzle quest data.',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0), // Add padding to the scroll view
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mini-Puzzle:',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold), // Use theme style
          ),
          const SizedBox(height: 8),
          Text(
            puzzleDescription,
            style: Theme.of(context)
                .textTheme
                .bodyLarge, // Use bodyLarge for description
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _answerController,
            decoration: const InputDecoration(
              labelText: 'Your Answer',
              border: OutlineInputBorder(),
            ),
            style: Theme.of(context)
                .textTheme
                .bodyLarge, // Ensure text in field scales
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
              style: ElevatedButton.styleFrom(
                minimumSize:
                    const Size(double.infinity, 50), // Ensure good tap target
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
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
        backgroundColor: Colors.red, // Ensure good contrast for error message
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
