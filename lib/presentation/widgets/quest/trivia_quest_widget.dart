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


// ========================================================================
// TRIVIA QUEST WIDGET
// Displays a trivia question (supports multiple choice) and handles submission.
// ========================================================================
class TriviaQuestWidget extends ConsumerStatefulWidget {
 // Assuming q.Quest entity has:
 // String? question;
 // List<String>? options; // For multiple choice
 // String? correctAnswer; // Or int? correctOptionIndex; - for validation (often done on backend)
 final q.Quest quest;

 const TriviaQuestWidget({super.key, required this.quest});

 @override
 ConsumerState<TriviaQuestWidget> createState() => _TriviaQuestWidgetState();
}

class _TriviaQuestWidgetState extends ConsumerState<TriviaQuestWidget> {
 // State to hold the currently selected option index for multiple choice
 int? _selectedOptionIndex;
 bool _isSubmitting = false; // To prevent multiple submissions

 @override
 Widget build(BuildContext context) {
 // Access the UseCase provider
  final submitTriviaUseCase = ref.read(submitTriviaAnswerUseCaseProvider);

  // Safely access quest data
   final question = widget.quest.question;
  final options = widget.quest.options; // Assuming 'options' field exists in q.Quest (List<String>?)

  // Determine if it's multiple choice or open text based on options availability
  final isMultipleChoice = options != null && options.isNotEmpty;

  if (question == null) {
  return const Center(child: Text('Invalid trivia quest data: Missing question.'));
  }

  // If it's multiple choice but options are missing/empty, show error
  if (isMultipleChoice && (options == null || options.isEmpty)) {
   return const Center(child: Text('Invalid trivia quest data: Missing options for multiple choice.'));
  }


  return SingleChildScrollView( // Use SingleChildScrollView if content can be long
 child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  // Display the question
   Text(
  'Question: $question',
  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  ),
  const SizedBox(height: 16),

 // Render either multiple choice options or a text field
   if (isMultipleChoice)
  _buildMultipleChoiceOptions(options!), // Pass non-nullable options
  // else
 //   _buildOpenTextInput(), // Implement if you need open text input

 const SizedBox(height: 16),

 // Submit button
  Center( // Center the button
  child: ElevatedButton(
 // Disable button if no option selected (for multiple choice) or if submitting
   onPressed: (_selectedOptionIndex == null && isMultipleChoice) || _isSubmitting
 ? null
 // For multiple choice, pass the text of the selected option
 : () => _handleSubmit(context, ref, submitTriviaUseCase, isMultipleChoice ? options![_selectedOptionIndex!] : 'N/A'), // Pass ref and submitted answer

 child: _isSubmitting
 ? const SizedBox( // Show spinner when submitting
  width: 20,
   height: 20,
  child: CircularProgressIndicator(
   color: Colors.white,
 strokeWidth: 3,
   ),
  )
  : const Text('Submit Answer'),
  ),
  ),
  ],
  ),
  );
  }

 // Builds the UI for multiple choice options
 Widget _buildMultipleChoiceOptions(List<String> options) {
 return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: options.asMap().entries.map((entry) {
 final index = entry.key;
  final optionText = entry.value;
  return RadioListTile<int>(
   title: Text(optionText),
  value: index, // The value of this radio button is its index
 groupValue: _selectedOptionIndex, // The currently selected value in the group
  onChanged: _isSubmitting ? null : (int? value) { // Disable while submitting
  setState(() {
  _selectedOptionIndex = value;
  });
  },
  );
  }).toList(),
  );
 }



  // Handle the submission logic
 Future<void> _handleSubmit(
  BuildContext context,
   WidgetRef ref, // Added ref to access AuthProvider
  SubmitQuestAnswerUseCase<SubmitTriviaAnswerParams> submitTriviaUseCase, // Use the specific type
   String submittedAnswer, // The answer to submit (option text or open text)
  ) async {
   setState(() {
  _isSubmitting = true; // Set submitting state
 });

  // Get the actual logged-in user's ID from AuthProvider
  final authProvider = ref.read(authProvider); // Assuming authProvider is a Riverpod provider
 final userId = authProvider.currentUser?.id;

  if (userId == null) {
  // Handle case where user is not logged in (shouldn't happen if routes are protected)
 _showError(context, const Failure(message: 'User not logged in. Cannot submit.'));
   setState(() { _isSubmitting = false; });
   return;
  }

  // Create parameters for the use case
  final params = SubmitTriviaAnswerParams(
  questId: widget.quest.id ?? '', // Use the quest ID
 answer: submittedAnswer,
   userId: userId,
 );

  // Call the use case to submit the answer
 final result = await submitTriviaUseCase(params);

 // Handle the result using fold
 result.fold(
 (failure) {
  _showError(context, failure);
 },
 (submissionResult) { // Use the QuestSubmissionResult from the service
 _showSuccess(context);
  // Navigate to QuestResultScreen with the result data
  GoRouter.of(context).go(AppConstants.questResultRoute, extra: {
  'isSuccessful': submissionResult.isSuccessful,
  'pointsEarned': submissionResult.pointsEarned,
   'feedbackMessage': submissionResult.feedbackMessage,
 'newBadges': submissionResult.newBadges,
  });

        // TODO: Optionally trigger a profile refresh if needed, although backend update + stream should handle this
        // ref.read(profileProvider.notifier).getUserProfile(userId); // Example if ProfileProvider has a notifier
  },
 );

 setState(() {
  _isSubmitting = false; // Reset submitting state
 });
  }

 // Extracted Error and Success Handlers
 void _showError(BuildContext context, Failure failure) {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: Text('Error: ${failure.message}'),
  backgroundColor: Colors.red,
 ),
 );
 }
  
  void _showError(BuildContext context, Failure failure) {
  ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Answer submitted successfully!')),
  );
  // Optionally reset selected option after successful submission
  setState(() {
  _selectedOptionIndex = null;
   });
 }

