import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart' as q; // Alias to avoid conflict

// Assuming these are defined in your project:
import 'package:final_project/domain/usecases/submit_quest_answer_usecase.dart'; // Import Use Case and Params
import 'package:final_project/core/error/failures.dart'; // Import Failure
import 'package:dartz/dartz.dart'; // Import Either
import 'package:final_project/presentation/providers/quest_provider.dart'; // Import providers

import 'package:go_router/go_router.dart'; // For navigation
import '../../../core/constants/app_constants.dart'; // For routes
import '../../providers/auth_provider.dart'; // Assuming AuthProvider for user ID

// Assuming SubmitPollVoteUseCase and its provider are defined elsewhere
// import 'package:final_project/domain/usecases/submit_poll_vote_usecase.dart';
// final submitPollVoteUseCaseProvider = Provider<SubmitQuestAnswerUseCase<SubmitPollVoteParams>>(...);


// ========================================================================
// POLL QUEST WIDGET (PLACEHOLDER)
// Displays a poll question and options.
// ========================================================================
class PollQuestWidget extends ConsumerStatefulWidget {
  // Assuming q.Quest entity has:
  // String? question;
  // List<PollOption>? options; // Define a PollOption class if needed
  final q.Quest quest;

  const PollQuestWidget({super.key, required this.quest});

  @override
  ConsumerState<PollQuestWidget> createState() => _PollQuestWidgetState();
}

class _PollQuestWidgetState extends ConsumerState<PollQuestWidget> {
  // State to hold the currently selected option ID
  String? _selectedOptionId;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    // Access the UseCase provider
    // final submitPollVoteUseCase = ref.read(submitPollVoteUseCaseProvider); // Uncomment when provider is ready

    // Safely access quest data
    final question = widget.quest.question; // Assuming 'question' field exists
    final options = widget.quest.options as List<Map<String, dynamic>>?; // Assuming 'options' is List of Maps {id, text}

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
          ...options.map((option) {
            final optionId = option['id'] as String?;
            final optionText = option['text'] as String?;

            if (optionId == null || optionText == null) return const SizedBox.shrink(); // Skip invalid options

            return RadioListTile<String>(
              title: Text(optionText),
              value: optionId,
              groupValue: _selectedOptionId,
              onChanged: _isSubmitting ? null : (String? value) {
                setState(() {
                  _selectedOptionId = value;
                });
              },
            );
          }).toList(),

          const SizedBox(height: 16),

          Center(
            child: ElevatedButton(
              onPressed: _selectedOptionId == null || _isSubmitting ? null : () {
                // TODO: Implement submission logic
                print('Submitting poll vote for option: $_selectedOptionId');
                // Example call to use case:
                // _handleSubmit(context, ref, submitPollVoteUseCase, _selectedOptionId!);
              },
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text('Submit Vote'),
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Implement _handleSubmit, _showError, _showSuccess methods similar to other widgets
  // Future<void> _handleSubmit(...) async { ... }
  // void _showError(BuildContext context, Failure failure) { ... }
  // void _showSuccess(BuildContext context) { ... }
}
