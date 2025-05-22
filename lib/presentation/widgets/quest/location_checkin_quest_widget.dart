import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dartz/dartz.dart';
import 'package:final_project/domain/entities/quest.dart'
    as q; // Import the domain Quest

// Assuming these are defined in your project:
import 'package:final_project/core/error/failures.dart'; // Import Failure and its concrete types
import 'package:final_project/presentation/providers/quest_provider.dart'; // Import providers
//import 'package:final_project/domain/usecases/submit_location_answer_usecase.dart'; // Import Use Case and Params
import 'package:final_project/domain/services/quest_submision_service.dart'; // Import SubmissionResult
// import 'package:final_project/presentation/providers/quest_provider.dart'; // Duplicate import, remove if not needed

import 'package:go_router/go_router.dart'; // For navigation
import '../../../core/constants/app_constants.dart'; // For routes
import '../../providers/auth_provider.dart'; // Assuming AuthProvider for user ID
import '../../../core/riverpodDI/providers.dart'; // To access locationServiceProvider (like locationServiceProvider)

// ========================================================================
// LOCATION CHECK-IN QUEST WIDGET
// Displays UI for location check-in and handles submission.
// ========================================================================
class LocationCheckInQuestWidget extends ConsumerStatefulWidget {
  final q.Quest quest; // Use the domain Quest

  const LocationCheckInQuestWidget({super.key, required this.quest});

  @override
  ConsumerState<LocationCheckInQuestWidget> createState() =>
      _LocationCheckInQuestWidgetState();
}

class _LocationCheckInQuestWidgetState
    extends ConsumerState<LocationCheckInQuestWidget> {
  Position? _currentPosition;
  String _locationStatus = 'Tap to get location';
  bool _isGettingLocation = false;
  bool _isSubmitting = false;

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() {
      _locationStatus = 'Getting location...';
      _isGettingLocation = true;
      _currentPosition = null; // Clear previous position
    });
    try {
      final position =
          await ref.read(locationServiceProvider).getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _locationStatus = 'Location acquired!';
      });
    } catch (e) {
      String errorMessage = 'Error getting location: $e';
      // Default to UnexpectedFailure if no specific match
      Failure specificFailure = UnexpectedFailure(message: errorMessage);

      if (e is LocationServiceDisabledException) {
        errorMessage = 'Location services are disabled. Please enable them.';
        specificFailure = const LocationServiceDisabledFailure();
      } else if (e is PermissionDeniedException) {
        errorMessage = 'Location permission denied. Please grant permission.';
        specificFailure = const LocationPermissionDeniedFailure();
      } else if (e is Failure) {
        // If the caught exception is already a Failure (e.g., from your LocationService), use it directly.
        specificFailure = e;
        errorMessage =
            'Location Error: ${e.message}'; // Update errorMessage for display
      }
      // No need for a final else as specificFailure is initialized to UnexpectedFailure

      setState(() {
        _locationStatus = errorMessage;
        _currentPosition = null; // Ensure position is null on error
      });
      _showError(context, specificFailure); // Show error snackbar
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitLocationUseCase = ref.read(submitLocationAnswerUseCaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Check-in your current location:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Status: $_locationStatus'),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _isGettingLocation
              ? null
              : _getCurrentLocation, // Disable while getting location
          child: _isGettingLocation
              ? const SizedBox(
                  // Show spinner when getting location
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Text('Get Current Location'),
        ),
        const SizedBox(height: 16),
        if (_currentPosition != null)
          ElevatedButton(
            onPressed: _isSubmitting
                ? null
                : () => _handleSubmit(context, ref,
                    submitLocationUseCase), // Disable while submitting
            child: _isSubmitting
                ? const SizedBox(
                    // Show spinner when submitting
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Text('Submit Location'),
          ),
      ],
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    WidgetRef ref, // Added ref to access AuthProvider
    SubmitQuestAnswerUseCase<SubmitLocationAnswerParams>
        submitLocationUseCase, // Use the specific type
  ) async {
    if (_currentPosition == null) {
      // Use InvalidInputFailure as it represents a validation error on input
      _showError(
          context,
          const InvalidInputFailure(
              message: 'Please get your location first.'));
      return;
    }

    setState(() {
      _isSubmitting = true; // Set submitting state
    });

    // Get the actual logged-in user's ID from AuthProvider
    // You need to ensure authProvider gives you an object that has 'currentUser' and 'currentUser.id'
    // For example, if authProvider exposes a StateNotifier that holds AuthState:
    // final authState = ref.read(authProvider);
    // final userId = authState.user?.id; // Assuming AuthState has a 'user' entity with an 'id'

    // If authProvider directly provides a User entity or a service that has a currentUser:
    final authService = ref.read(authProvider); // Access the service/notifier
    final userId = authService.currentUser?.id; // Access currentUser and its id

    if (userId == null) {
      // Use AuthenticationFailure for user not logged in
      _showError(
          context,
          const AuthenticationFailure(
              message: 'User not logged in. Cannot submit.'));
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final params = SubmitLocationAnswerParams(
      questId: widget.quest.id ?? '',
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      userId: userId,
    );

    final result = await submitLocationUseCase(params);

    result.fold(
      (failure) {
        _showError(context, failure);
      },
      (submissionResult) {
        // Use the QuestSubmissionResult from the service
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
      const SnackBar(content: Text('Location submitted!')),
    );
  }
}
