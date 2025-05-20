import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class QuestResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;

  const QuestResultScreen({super.key, required this.resultData});

  @override
  Widget build(BuildContext context) {
    final isSuccessful = resultData['isSuccessful'] as bool? ?? false;
    final pointsEarned = resultData['pointsEarned'] as int? ?? 0;
    final feedbackMessage =
        resultData['feedbackMessage'] as String? ?? 'No feedback.';
    final newBadges = resultData['newBadges'] as List<String>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Result'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccessful
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                color: isSuccessful
                    ? Colors.green
                    : Colors.red, // Good contrast for status icons
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                isSuccessful ? 'Quest Completed!' : 'Quest Failed!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isSuccessful
                          ? Colors.green
                          : Colors.red, // Good contrast for status text
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                feedbackMessage,
                style:
                    Theme.of(context).textTheme.titleMedium, // Good for scaling
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (isSuccessful)
                Text(
                  'Points Earned: $pointsEarned',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge, // Good for scaling
                ),
              const SizedBox(height: 24),
              if (newBadges.isNotEmpty) ...[
                Text(
                  'New Badges Earned:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold), // Good for scaling
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  alignment: WrapAlignment.center,
                  children: newBadges
                      .map((badge) => Chip(
                            label: Text(
                              badge,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall, // Ensure chip text scales
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go(AppConstants.homeRoute);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: Theme.of(context)
                      .textTheme
                      .titleMedium, // Use theme text style for button text
                  minimumSize: const Size(150, 50), // Ensure good tap target
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
