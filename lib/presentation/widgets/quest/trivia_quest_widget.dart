import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/presentation/providers/quest_provider.dart';

class TriviaQuestWidget extends ConsumerWidget {
  final Quest quest;
  final TextEditingController _answerController = TextEditingController();

  TriviaQuestWidget({super.key, required this.quest});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitTrivia = ref.read(submitTriviaAnswerUseCaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (quest.data?['question'] != null)
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
              await submitTrivia.execute(
                SubmitTriviaAnswerParams(
                    questId: quest.id, answer: _answerController.text),
              );
              // Optionally show a feedback message or navigate to the result screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Answer submitted!')),
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
