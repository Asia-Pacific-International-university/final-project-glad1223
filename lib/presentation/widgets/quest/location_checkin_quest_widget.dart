import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/core/services/location_service.dart'; // Import LocationService
import 'package:geolocator/geolocator.dart'; // You'll need this package
import 'package:final_project/core/usecases/usecase.dart'; // Import usecase.dart
import 'package:final_project/domain/repositories/quest_repository.dart'; // Import QuestRepository

// Define the SubmitLocationAnswerParams and UseCase in your providers or usecases
class SubmitLocationAnswerParams {
  final String questId;
  final double latitude;
  final double longitude;

  SubmitLocationAnswerParams(
      {required this.questId, required this.latitude, required this.longitude});
}

class SubmitLocationAnswerUseCase
    implements ParamFutureUseCase<SubmitLocationAnswerParams, void> {
  // Implement ParamFutureUseCase
  final QuestRepository _questRepository;

  SubmitLocationAnswerUseCase({required QuestRepository questRepository})
      : _questRepository = questRepository;

  @override
  Future<Either<Failure, void>> call(SubmitLocationAnswerParams params) async {
    // Use call and Either
    // Assuming submitCheckInLocation returns Future<Either<Failure, void>>
    return await _questRepository.submitCheckInLocation(
      params.questId,
      params.latitude,
      params.longitude,
    );
  }
}

//  QuestRepository provider (ensure this is defined correctly)
final questRepositoryProvider = Provider<QuestRepository>((ref) {
  throw UnimplementedError(); //  Implement this provider
});

final submitLocationAnswerUseCaseProvider =
    Provider<SubmitLocationAnswerUseCase>(
  (ref) => SubmitLocationAnswerUseCase(
    questRepository: ref.read(questRepositoryProvider),
  ),
);

class LocationCheckInQuestWidget extends ConsumerStatefulWidget {
  final Quest quest;

  const LocationCheckInQuestWidget({super.key, required this.quest});

  @override
  ConsumerState<LocationCheckInQuestWidget> createState() =>
      _LocationCheckInQuestWidgetState();
}

class _LocationCheckInQuestWidgetState
    extends ConsumerState<LocationCheckInQuestWidget> {
  Position? _currentPosition;
  String _locationStatus = 'Tap to get location';

  Future<void> _getCurrentLocation() async {
    setState(() {
      _locationStatus = 'Getting location...';
    });
    try {
      final position =
          await ref.read(locationServiceProvider).getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _locationStatus = 'Location acquired!';
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submitLocation = ref.read(submitLocationAnswerUseCaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Check-in your current location:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Status: $_locationStatus'),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _getCurrentLocation,
          child: const Text('Get Current Location'),
        ),
        const SizedBox(height: 16),
        if (_currentPosition != null)
          ElevatedButton(
            onPressed: () async {
              try {
                final result = await submitLocation.call(
                  // Use call()
                  SubmitLocationAnswerParams(
                    questId: widget.quest.id,
                    latitude: _currentPosition!.latitude,
                    longitude: _currentPosition!.longitude,
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
                      const SnackBar(content: Text('Location submitted!')),
                    );
                  },
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('An unexpected error occurred: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit Location'),
          ),
      ],
    );
  }
}

// Ensure you have a LocationService provider defined, e.g.:
final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());
