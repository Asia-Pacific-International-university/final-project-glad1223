import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/presentation/providers/quest_provider.dart';
import 'package:final_project/domain/entities/quest.dart'
    as q; // Alias to avoid conflict
import 'package:final_project/presentation/widgets/quest/trivia_quest_widget.dart';
import 'package:final_project/presentation/widgets/quest/location_checkin_quest_widget.dart';
import 'package:final_project/presentation/widgets/quest/photo_challenge_quest_widget.dart';
import 'package:final_project/presentation/widgets/quest/poll_quest_widget.dart';
import 'package:final_project/presentation/widgets/quest/mini_puzzle_quest_widget.dart';

import 'package:final_project/presentation/adapters/location_checkin_quest_adapter.dart';
import 'package:final_project/presentation/adapters/photo_challenge_quest_adapter.dart';
import 'package:final_project/core/constants/app_constants.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

class ActiveQuestScreen extends ConsumerStatefulWidget {
  const ActiveQuestScreen({super.key});

  @override
  ConsumerState<ActiveQuestScreen> createState() => _ActiveQuestScreenState();
}

class _ActiveQuestScreenState extends ConsumerState<ActiveQuestScreen> {
  Timer? _questTimer;
  Duration _remainingTime = AppConstants.questTimerDuration;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _questTimer?.cancel();
    super.dispose();
  }

  void _startOrResetQuestTimer(Duration duration) {
    if (!_isTimerRunning || _remainingTime != duration) {
      _questTimer?.cancel();

      setState(() {
        _remainingTime = duration;
        _isTimerRunning = true;
      });

      _questTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTime.inSeconds > 0) {
          setState(() {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          });
        } else {
          _questTimer?.cancel();
          setState(() {
            _isTimerRunning = false;
          });
          print('Quest timer finished!');
          GoRouter.of(context).go(AppConstants.questResultRoute, extra: {
            'isSuccessful': false,
            'pointsEarned': 0,
            'feedbackMessage': 'Time ran out!',
            'newBadges': [],
          });
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final questState = ref.watch(questProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Quest'),
        actions: [
          if (questState.hasValue &&
              questState.value != null &&
              questState.value!.duration != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  _formatDuration(_remainingTime),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _remainingTime.inSeconds <= 10 &&
                                _remainingTime.inSeconds > 0
                            ? Colors.red
                            : null,
                        fontWeight: FontWeight
                            .bold, // Make timer text bolder for readability
                      ),
                ),
              ),
            ),
        ],
      ),
      body: questState.when(
        data: (quest) {
          if (quest != null && quest.duration != null) {
            _startOrResetQuestTimer(quest.duration!);
          } else {
            _questTimer?.cancel();
            _isTimerRunning = false;
          }

          if (quest == null) {
            _questTimer?.cancel();
            _isTimerRunning = false;
            return Center(
              child: Text(
                'No active quest at the moment.',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium, // Use theme text style
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall, // Good for scaling
                ),
                const SizedBox(height: 8),
                Text(
                  quest.description ?? 'No Description',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge, // Use bodyLarge for description text
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _buildQuestContent(quest, ref, context),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading quest: ${error.toString()}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .error), // Use error color from theme
          ),
        ),
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
        return PollQuestWidget(quest: quest);
      case q.QuestType.locationCheckIn:
        return LocationCheckInQuestWidget(
            quest: LocationCheckInQuestAdapter(quest));
      case q.QuestType.photoChallenge:
        return PhotoChallengeQuestWidget(
            quest: PhotoChallengeQuestAdapter(quest));
      case q.QuestType.miniPuzzle:
        return MiniPuzzleQuestWidget(quest: quest);
      default:
        return Center(
          child: Text(
            'Unknown quest type: ${quest.type}',
            style:
                Theme.of(context).textTheme.titleMedium, // Use theme text style
          ),
        );
    }
  }
}
