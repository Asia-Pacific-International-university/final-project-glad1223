import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart'
    as q; // Alias to avoid conflict

// Assuming these are defined in your project:
import 'package:final_project/domain/usecases/submit_quest_answer_usecase.dart'; // Import Use Case and Params
import 'package:final_project/core/error/failures.dart'; // Import Failure
// import 'package:dartz/dartz.dart'; // Import Either
// import 'package:final_project/presentation/providers/quest_provider.dart'; // Import providers
// import 'package:final_project/domain/services/quest_submision_service.dart'; // Import SubmissionResult

import 'package:go_router/go_router.dart'; // For navigation
import '../../../core/constants/app_constants.dart'; // For routes
import '../../providers/auth_provider.dart'; // Assuming AuthProvider for user ID

// Import the Riverpod provider for SubmitPollVoteUseCase
import '../../../core/riverpodDI/providers.dart';
//import 'package:final_project/domain/usecases/submit_poll_vote_usecase.dart';

// ========================================================================
// POLL QUEST WIDGET (PLACEHOLDER)
// Displays a poll question and options.
// ========================================================================
class PollQuestWidget extends ConsumerStatefulWidget {
  // Assuming q.Quest entity has:
  // String? question;
  // List<String>? options; // For poll options (assuming simple string options)
  final q.Quest quest;

  const PollQuestWidget({super.key, required this.quest});

  @override
  ConsumerState<PollQuestWidget> createState() => _PollQuestWidgetState();
}

class _PollQuestWidgetState extends ConsumerState<PollQuestWidget> {
  String? _selectedOption; // Store the selected option text
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final submitPollVoteUseCase = ref.read(submitPollVoteUseCaseProvider);

    final question = widget.quest.question;
    final options = widget.quest.options; // Assuming 'options' is List<String>

    if (question == null || options == null || options.isEmpty) {
      return const Center(child: Text('Invalid poll quest data.'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Poll Question: $question',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),

          // Display poll options
          ...options.map((optionText) {
            return RadioListTile<String>(
              title: Text(optionText),
              value: optionText, // Use the option text as the value
              groupValue: _selectedOption,
              onChanged: _isSubmitting
                  ? null
                  : (String? value) {
                      setState(() {
                        _selectedOption = value;
                      });
                    },
            );
          }).toList(),

          const SizedBox(height: 16),

          Center(
            child: ElevatedButton(
              onPressed: _selectedOption == null || _isSubmitting
                  ? null
                  : () {
                      _handleSubmit(context, ref, submitPollVoteUseCase,
                          _selectedOption!); // Null-assert _selectedOption here as it's checked above
                    },
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3),
                    )
                  : const Text('Submit Vote'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref,
    SubmitQuestAnswerUseCase<SubmitPollVoteParams> submitPollVoteUseCase,
    String submittedOption,
  ) async {
    setState(() {
      _isSubmitting = true;
    });

    // Access the user ID from the AuthState provided by authProvider
    final userId = ref.read(authProvider).currentUser?.id;

    if (userId == null) {
      _showError(context,
          const Failure(message: 'User not logged in. Cannot submit.'));
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final params = SubmitPollVoteParams(
      questId: widget.quest.id ?? '',
      optionId:
          submittedOption, // Assuming optionId is the option text itself for simplicity
      userId: userId,
    );

    final result = await submitPollVoteUseCase(params);

    result.fold(
      (failure) {
        _showError(context, failure);
      },
      (submissionResult) {
        _showSuccess(context);
        GoRouter.of(context).go(AppConstants.questResultRoute, extra: {
          'isSuccessful': submissionResult!.isSuccessful, // Null assertion
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
      const SnackBar(content: Text('Poll vote submitted!')),
    );
    setState(() {
      _selectedOption = null;
    });
  }
}
