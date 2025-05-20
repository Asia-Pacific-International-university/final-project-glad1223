import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:final_project/domain/entities/quest.dart'
    as q; // Import the domain Quest

// Assuming these are defined in your project:
import 'package:final_project/core/error/failures.dart'; // Import Failure
import 'package:final_project/domain/usecases/submit_quest_answer_usecase.dart'; // Import Use Case and Params
import 'package:final_project/domain/services/quest_submission_service.dart'; // Import SubmissionResult
import 'package:final_project/presentation/providers/quest_provider.dart'; // Import providers

import 'package:go_router/go_router.dart'; // For navigation
import '../../../core/constants/app_constants.dart'; // For routes
import '../../providers/auth_provider.dart'; // Assuming AuthProvider for user ID

// Assuming CameraService and its provider are defined elsewhere
// import 'package:final_project/core/services/camera_service.dart';
// final cameraServiceProvider = Provider<CameraService>((ref) => CameraService());

// Assuming SubmitPhotoAnswerUseCase and its provider are defined elsewhere
// import 'package:final_project/domain/usecases/submit_photo_answer_usecase.dart';
// final submitPhotoAnswerUseCaseProvider = Provider<SubmitQuestAnswerUseCase<SubmitPhotoAnswerParams>>(...);


// ========================================================================
// PHOTO CHALLENGE QUEST WIDGET
// Displays UI for photo challenge and handles submission.
// ========================================================================
class PhotoChallengeQuestWidget extends ConsumerStatefulWidget {
  final q.Quest quest; // Use the domain Quest

  const PhotoChallengeQuestWidget({super.key, required this.quest});

  @override
  ConsumerState<PhotoChallengeQuestWidget> createState() =>
      _PhotoChallengeQuestWidgetState();
}

class _PhotoChallengeQuestWidgetState
    extends ConsumerState<PhotoChallengeQuestWidget> {
  File? _pickedImage;
  bool _isPickingImage = false;
  bool _isSubmitting = false;


  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
      _pickedImage = null; // Clear previous image
    });
    try {
      // You might offer a choice between camera and gallery
      final pickedFile =
          await ref.read(cameraServiceProvider).pickImage(ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle potential errors during image picking (e.g., permissions)
      print('Error picking image: $e');
      _showError(context, Failure(message: 'Failed to pick image: ${e.toString()}'));
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitPhotoUseCase = ref.read(submitPhotoAnswerUseCaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Capture a photo for the challenge:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _isPickingImage ? null : _pickImage, // Disable while picking
          child: _isPickingImage
              ? const SizedBox( // Show spinner when picking
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                )
              : const Text('Take Photo'),
        ),
        const SizedBox(height: 16),
        if (_pickedImage != null) ...[
          SizedBox(
            height: 200, // Increased height for better preview
            width: double.infinity,
            child: Image.file(
              _pickedImage!,
              fit: BoxFit.contain, // Use contain to show the full image
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSubmitting ? null : () => _handleSubmit(context, ref, submitPhotoUseCase), // Disable while submitting
            child: _isSubmitting
                  ? const SizedBox( // Show spinner when submitting
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('Submit Photo'),
          ),
        ],
      ],
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref, // Added ref to access AuthProvider
    SubmitQuestAnswerUseCase<SubmitPhotoAnswerParams> submitPhotoUseCase, // Use the specific type
  ) async {
    if (_pickedImage == null) {
      _showInputError(context);
      return;
    }

    setState(() {
      _isSubmitting = true; // Set submitting state
    });

    // Get the actual logged-in user's ID from AuthProvider
    final authProvider = ref.read(authProvider); // Assuming authProvider is a Riverpod provider
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      _showError(context, const Failure(message: 'User not logged in. Cannot submit.'));
      setState(() { _isSubmitting = false; });
      return;
    }


    final params = SubmitPhotoAnswerParams(
      questId: widget.quest.id ?? '',
      imagePath: _pickedImage!.path,
      userId: userId,
    );

    final result = await submitPhotoUseCase(params);

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


  void _showError(BuildContext context, Failure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${failure.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo submitted!')),
    );
    // Optionally clear the picked image after successful submission
    setState(() {
      _pickedImage = null;
    });
  }

  void _showInputError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please take a photo first.')),
    );
  }
}
