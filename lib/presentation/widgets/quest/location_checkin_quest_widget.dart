import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/core/services/location_service.dart'; // Import LocationService
import 'package:geolocator/geolocator.dart'; // You'll need this package

// Define the SubmitLocationAnswerParams and UseCase in your providers or usecases
class SubmitLocationAnswerParams {
  final String questId;
  final double latitude;
  final double longitude;

  SubmitLocationAnswerParams(
      {required this.questId, required this.latitude, required this.longitude});
}

class SubmitLocationAnswerUseCase
    implements FutureUseCase<void, SubmitLocationAnswerParams> {
  final QuestRepository _questRepository;

  SubmitLocationAnswerUseCase({required this.questRepository});

  @override
  Future<void> execute(SubmitLocationAnswerParams params) async {
    return await _questRepository.submitCheckInLocation(
        params.questId, params.latitude, params.longitude);
  }
}

final submitLocationAnswerUseCaseProvider =
    Provider<SubmitLocationAnswerUseCase>(
  (ref) => SubmitLocationAnswerUseCase(
      questRepository: ref.read(questRepositoryProvider)),
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
              await submitLocation.execute(
                SubmitLocationAnswerParams(
                  questId: widget.quest.id,
                  latitude: _currentPosition!.latitude,
                  longitude: _currentPosition!.longitude,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location submitted!')),
              );
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
