import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/presentation/providers/quest_provider.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/presentation/widgets/quest/trivia_quest_widget.dart';
import 'package:final_project/presentation/widgets/quest/location_checkin_quest_widget.dart';
import 'package:final_project/presentation/widgets/quest/photo_challenge_quest_widget.dart';
// Import other quest type widgets

class ActiveQuestScreen extends ConsumerWidget {
  const ActiveQuestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questState = ref.watch(questProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Quest'),
      ),
      body: questState.when(
        data: (quest) {
          if (quest == null) {
            return const Center(child: Text('No active quest at the moment.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    quest.question ??
                        quest.photoTheme ??
                        quest.locationName ??
                        'New Quest', // Display relevant title
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(quest.description ?? ''),
                const SizedBox(height: 16),
                _buildQuestContent(quest, ref),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error loading quest: $error')),
      ),
    );
  }

  Widget _buildQuestContent(Quest? quest, WidgetRef ref) {
    if (quest == null) {
      return const SizedBox.shrink();
    }
    switch (quest.type) {
      case QuestType.trivia:
        return TriviaQuestWidget(quest: quest);
      case QuestType.poll:
        return const Text(
            'Quick Poll UI will be here'); // Implement QuickPollQuestWidget
      case QuestType.locationCheckIn:
        return LocationCheckInQuestWidget(quest: quest);
      case QuestType.photoChallenge:
        return PhotoChallengeQuestWidget(quest: quest);
      case QuestType.miniPuzzle:
        return const Text(
            'Mini Puzzle UI will be here'); // Implement MiniPuzzleQuestWidget
      default:
        return const Text('Unknown quest type');
    }
  }
}
