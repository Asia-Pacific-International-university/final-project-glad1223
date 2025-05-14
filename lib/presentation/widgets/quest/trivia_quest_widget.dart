import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/presentation/providers/quest_provider.dart'; // Import for provider
//import 'package:final_project/domain/usecases/submit_quest_answer_usecase.dart'; // Import the UseCase
//import 'package:final_project/core/usecases/usecase.dart'; // Import the UseCase
//import 'package:dartz/dartz.dart'; // Import Either
//import 'package:final_project/core/error/failures.dart'; // Import Failure

class TriviaQuestWidget extends ConsumerWidget {
  final Quest quest;
  final TextEditingController _answerController = TextEditingController();

  TriviaQuestWidget({super.key, required this.quest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitTrivia =
        ref.read(submitQuestAnswerUseCaseProvider); // Corrected provider name

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Access quest data correctly.  Assuming quest.data is a Map<String, dynamic>?
        if (quest.data != null && quest.data!['question'] != null)
          Text('Question: ${quest.data!['question']}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
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
          onPressed: () async {
            if (_answerController.text.isNotEmpty) {
              final result = await submitTrivia.call(
                // Use .call()
                ProcessQuestSubmissionParams(
                  // Use the correct Params class
                  questId: quest.id,
                  answer: _answerController.text,
                  userId:
                      'user_id', //  Pass the actual user ID.  You'll need to get this from your auth system.
                  pointsAwarded:
                      10, //  Pass the correct point value.  This might come from the quest data.
                ),
              );
              result.fold(
                (failure) {
                  // Handle failure (e.g., show error message)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${failure.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                (success) {
                  // Handle success (e.g., show success message)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Answer submitted!')),
                  );
                  _answerController.clear(); // Clear the input field
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter your answer.')),
              );
            }
          },
          child: const Text('Submit Answer'),
        ),
      ],
    );
  }
}
