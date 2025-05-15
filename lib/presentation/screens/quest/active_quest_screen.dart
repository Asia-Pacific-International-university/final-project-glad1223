import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/presentation/providers/quest_provider.dart';
import 'package:final_project/domain/entities/quest.dart' as q;
import 'package:final_project/presentation/widgets/quest/trivia_quest_widget.dart';
import 'package:final_project/presentation/widgets/quest/location_checkin_quest_widget.dart';
import 'package:final_project/presentation/widgets/quest/photo_challenge_quest_widget.dart';
import 'package:final_project/presentation/adapters/location_checkin_quest_adapter.dart';
import 'package:final_project/presentation/adapters/photo_challenge_quest_adapter.dart';

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
                  quest.title ??
                      '', // Use null-aware operator to provide a default value
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(quest.description ?? 'No Description'),
                const SizedBox(height: 16),
                _buildQuestContent(quest, ref, context),
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

  Widget _buildQuestContent(
    q.Quest? quest,
    WidgetRef ref,
    BuildContext context,
  ) {
    if (quest == null) {
      return const SizedBox.shrink();
    }
    switch (quest.type) {
      case q.QuestType.trivia:
        return TriviaQuestWidget(quest: quest);
      case q.QuestType.poll:
        return const Text('Quick Poll UI will be here');
      case q.QuestType.locationCheckIn:
        return LocationCheckInQuestWidget(
            quest: LocationCheckInQuestAdapter(quest));
      case q.QuestType.photoChallenge:
        return PhotoChallengeQuestWidget(
            quest: PhotoChallengeQuestAdapter(quest));
      case q.QuestType.miniPuzzle:
        return const Text('Mini Puzzle UI will be here');
      default:
        return Text('Unknown quest type: ${quest.type}');
    }
  }
}
