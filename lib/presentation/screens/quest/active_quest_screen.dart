import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/presentation/providers/quest_provider.dart';
import 'package:final_project/domain/entities/quest.dart' as q; // Alias to avoid conflict
import 'package:final_project/presentation/widgets/quest/trivia_quest_widget.dart';
import 'package:final_project/presentation/widgets/quest/location_checkin_quest_widget.dart';
import 'package:final_project/presentation/widgets/quest/photo_challenge_quest_widget.dart';
// Import new placeholder widgets
import 'package:final_project/presentation/widgets/quest/poll_quest_widget.dart';
import 'package:final_project/presentation/widgets/quest/mini_puzzle_quest_widget.dart';


import 'package:final_project/presentation/adapters/location_checkin_quest_adapter.dart';
import 'package:final_project/presentation/adapters/photo_challenge_quest_adapter.dart';
import 'package:final_project/core/constants/app_constants.dart'; // Import AppConstants for timer duration
import 'dart:async'; // Import for Timer
import 'package:go_router/go_router.dart'; // Import GoRouter for navigation

// ========================================================================
// ACTIVE QUEST SCREEN
// Displays the currently active quest and its specific UI.
// Manages the quest timer.
// ========================================================================
class ActiveQuestScreen extends ConsumerStatefulWidget {
  const ActiveQuestScreen({super.key});

  @override
  ConsumerState<ActiveQuestScreen> createState() => _ActiveQuestScreenState();
}

class _ActiveQuestScreenState extends ConsumerState<ActiveQuestScreen> {
  Timer? _questTimer;
  // Initialize with a default or get from quest data later
  Duration _remainingTime = AppConstants.questTimerDuration;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    // Fetch the active quest when the screen initializes
    // The QuestNotifier's constructor already calls fetchActiveQuest(),
    // but you might want to re-fetch if navigating back to this screen.
    // ref.read(questProvider.notifier).fetchActiveQuest(); // Uncomment if needed

    // Start the timer when the quest data is loaded
    // We'll add logic in the builder to start/reset the timer
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to prevent memory leaks
    _questTimer?.cancel();
    super.dispose();
  }

  // Starts or resets the quest timer
  void _startOrResetQuestTimer(Duration duration) {
    // Only start/reset if the duration is valid and timer is not already running for this duration
    if (!_isTimerRunning || _remainingTime != duration) {
      _questTimer?.cancel(); // Cancel any existing timer

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
          // Timer finished
          _questTimer?.cancel();
          setState(() { _isTimerRunning = false; });
          print('Quest timer finished!');
          // TODO: Handle quest expiration (e.g., show failure, navigate away)
          // Navigate to QuestResultScreen with failure data
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

  // Helper to format duration as MM:SS
  String _formatDuration(Duration duration) {
    if (duration.isNegative) return '00:00'; // Handle negative duration
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    // Watch the quest state from the provider
    final questState = ref.watch(questProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Quest'),
        actions: [
          // Display the quest timer in the AppBar
          // Only show timer if a quest is loaded and has a duration
          if (questState.hasValue && questState.value != null && questState.value!.duration != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  _formatDuration(_remainingTime),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _remainingTime.inSeconds <= 10 && _remainingTime.inSeconds > 0 ? Colors.red : null, // Highlight last 10 seconds
                  ),
                ),
              ),
            ),
        ],
      ),
      body: questState.when(
        data: (quest) {
          // If quest data is loaded and it has a duration, start/reset the timer
          if (quest != null && quest.duration != null) {
            _startOrResetQuestTimer(quest.duration!);
          } else {
            // If no quest or no duration, ensure timer is stopped
            _questTimer?.cancel();
            _isTimerRunning = false;
        }


          if (quest == null) {
            // If no active quest, cancel timer and show message
            _questTimer?.cancel();
            _isTimerRunning = false;
            return const Center(child: Text('No active quest at the moment.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title ?? '',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(quest.description ?? 'No Description'),
                const SizedBox(height: 16),
                // Dynamically build quest content based on type
                Expanded( // Use Expanded to allow quest widgets to fill space
                  child: _buildQuestContent(quest, ref, context),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error loading quest: ${error.toString()}')), // Use toString() for error
      ),
    );
  }

  // Helper method to build the specific quest widget
  Widget _buildQuestContent(
    q.Quest? quest,
    WidgetRef ref,
    BuildContext context,
  ) {
    if (quest == null) {
      return const SizedBox.shrink(); // Should not happen based on parent logic, but safe
    }
    switch (quest.type) {
      case q.QuestType.trivia:
        // Pass the quest object to the TriviaQuestWidget
        return TriviaQuestWidget(quest: quest);
      case q.QuestType.poll:
        // Use the PollQuestWidget placeholder
        return PollQuestWidget(quest: quest);
      case q.QuestType.locationCheckIn:
        // Pass the adapted quest (though adapter currently just wraps)
        return LocationCheckInQuestWidget(
            quest: LocationCheckInQuestAdapter(quest));
      case q.QuestType.photoChallenge:
        // Pass the adapted quest (though adapter currently just wraps)
        return PhotoChallengeQuestWidget(
            quest: PhotoChallengeQuestAdapter(quest));
      case q.QuestType.miniPuzzle:
        // Use the MiniPuzzleQuestWidget placeholder
        return MiniPuzzleQuestWidget(quest: quest);
      default:
        return Center(child: Text('Unknown quest type: ${quest.type}'));
    }
  }
}
