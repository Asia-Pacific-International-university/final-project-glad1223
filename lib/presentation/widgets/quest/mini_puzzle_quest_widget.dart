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

// Assuming SubmitMiniPuzzleAnswerUseCase and its provider are defined elsewhere
// import 'package:final_project/domain/usecases/submit_mini_puzzle_answer_usecase.dart';
// final submitMiniPuzzleAnswerUseCaseProvider = Provider<SubmitQuestAnswerUseCase<SubmitMiniPuzzleAnswerParams>>(...);


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
  ConsumerState<MiniPuzzleQuestWidget> createState() => _MiniPuzzleQuestWidgetState();
}

class _MiniPuzzleQuestWidgetState extends ConsumerState<MiniPuzzleQuestWidget> {
  // State for the puzzle input/interaction
  // Example: TextEditingController for a text-based answer
  final TextEditingController _answerController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the UseCase provider
    // final submitMiniPuzzleUseCase = ref.read(submitMiniPuzzleAnswerUseCaseProvider); // Uncomment when provider is ready

    // Safely access quest data
    final puzzleDescription = widget.quest.description; // Assuming puzzle description is in description field
    // final puzzleData = widget.quest.puzzleData; // Assuming a specific field for puzzle data

    if (puzzleDescription == null /* || puzzleData == null */) {
      return const Center(child: Text('Invalid mini-puzzle quest data.'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mini-Puzzle:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(puzzleDescription), // Display puzzle description/instructions
          const SizedBox(height: 16),

          // TODO: Implement the actual puzzle UI here
          // This might be interactive widgets, or just an input field for the answer

          // Example: Text input for a simple answer
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
              onPressed: _isSubmitting || _answerController.text.trim().isEmpty ? null : () {
                // TODO: Implement submission logic
                print('Submitting puzzle answer: ${_answerController.text.trim()}');
                // Example call to use case:
                // _handleSubmit(context, ref, submitMiniPuzzleUseCase, _answerController.text.trim());
              },
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text('Submit Answer'),
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
