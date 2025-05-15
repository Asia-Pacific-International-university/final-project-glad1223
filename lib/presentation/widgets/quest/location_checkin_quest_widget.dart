import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dartz/dartz.dart';
import 'package:final_project/domain/entities/quest.dart'
    as q; // Import the domain Quest

// 1. Domain Entity (Use the domain Quest - q.Quest)
// class Quest {
//  final String? id;
//  // Add other relevant quest properties
//  Quest({this.id});
//}  REMOVED

// 2. Failure Class Hierarchy (Simplified and Corrected)
abstract class Failure {
  final String message;
  Failure({required this.message});
}

class LocationFailure extends Failure {
  LocationFailure({required String message}) : super(message: message);
}

class ServerFailure extends Failure {
  ServerFailure({String? message}) : super(message: message ?? 'Server Error');
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure({String? message})
      : super(message: message ?? 'Unexpected Error');
}

// 3. UseCase Interface
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// 4. Define Parameters Class
class SubmitLocationAnswerParams {
  final String questId;
  final double latitude;
  final double longitude;

  SubmitLocationAnswerParams({
    required this.questId,
    required this.latitude,
    required this.longitude,
  });
}

// 5. Define UseCase
class SubmitLocationAnswerUseCase
    implements UseCase<void, SubmitLocationAnswerParams> {
  final QuestRepository _questRepository;

  SubmitLocationAnswerUseCase({required QuestRepository questRepository})
      : _questRepository = questRepository;

  @override
  Future<Either<Failure, void>> call(SubmitLocationAnswerParams params) async {
    try {
      print(
          'SubmitLocationAnswerUseCase: questId=${params.questId}, latitude=${params.latitude}, longitude=${params.longitude}'); // Add logging
      await _questRepository.submitCheckInLocation(
          params.questId, params.latitude, params.longitude);
      print(
          'SubmitLocationAnswerUseCase: Repository call successful'); // Add logging
      return const Right(null);
    } on Failure catch (failure) {
      print(
          'SubmitLocationAnswerUseCase: Failure: ${failure.message}'); // Add logging
      return Left(failure);
    } catch (e) {
      print('SubmitLocationAnswerUseCase: Unexpected error: $e'); // Add logging
      return Left(UnexpectedFailure(message: 'Unexpected error: $e'));
    }
  }
}

// 6. Abstract Repository
abstract class QuestRepository {
  Future<void> submitCheckInLocation(
      String questId, double latitude, double longitude);
  // Add other repository methods as needed
}

// 7. *Mock* Repository Implementation
class MockQuestRepository implements QuestRepository {
  @override
  Future<void> submitCheckInLocation(
      String questId, double latitude, double longitude) async {
    print(
        'MockQuestRepository: questId=$questId, latitude=$latitude, longitude=$longitude'); // Add logging
    // Simulate a successful submission
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate errors based on input (for testing)
    if (latitude == 0.0 && longitude == 0.0) {
      print('MockQuestRepository: Throwing LocationFailure');
      throw LocationFailure(message: 'Invalid coordinates');
    }
    if (questId == 'error_quest') {
      print('MockQuestRepository: Throwing ServerFailure');
      throw ServerFailure(message: 'Simulated server error');
    }
    print('MockQuestRepository: Success');
    return Future.value(); // Return a completed Future<void>
  }
}

// 8. Location Service (Simplified)
class LocationService {
  Future<Position> getCurrentLocation() async {
    print('LocationService: getCurrentLocation called'); // Add logging
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('LocationService: Location services are disabled');
      throw LocationServiceDisabledException();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('LocationService: Location permissions are denied');
        throw PermissionDeniedException('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('LocationService: Location permissions are permanently denied');
      throw LocationFailure(
          message:
              'Location permissions are permanently denied.'); // Changed to use LocationFailure
    }
    print('LocationService: Getting current position');
    final position = await Geolocator.getCurrentPosition();
    print('LocationService: Got position: $position');
    return position;
  }
}

// 9. Providers
final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());
final questRepositoryProvider =
    Provider<QuestRepository>((ref) => MockQuestRepository()); // Use Mock
final submitLocationAnswerUseCaseProvider =
    Provider<SubmitLocationAnswerUseCase>(
  (ref) => SubmitLocationAnswerUseCase(
    questRepository: ref.read(questRepositoryProvider),
  ),
);

// 10. LocationCheckInQuestWidget
class LocationCheckInQuestWidget extends ConsumerStatefulWidget {
  final q.Quest quest; // Use the domain Quest

  const LocationCheckInQuestWidget({super.key, required this.quest});

  @override
  ConsumerState<LocationCheckInQuestWidget> createState() =>
      _LocationCheckInQuestWidgetState();
}

// class LocationCheckInQuest extends q.Quest {  // Remove this
//  final String locationName;
//
//  LocationCheckInQuest({
//    required super.id,
//    required super.type,
//    required super.title,
//    super.description,
//    required this.locationName,
//  });
//}

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
      String errorMessage = 'Error getting location: $e';
      if (e is LocationServiceDisabledException) {
        errorMessage = 'Location services are disabled.';
      } else if (e is PermissionDeniedException) {
        errorMessage = 'Location permission denied.';
      } else {
        // Handle the general case
        errorMessage = 'Error: ${e.toString()}';
      }
      setState(() {
        _locationStatus = errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed WidgetRef ref
    final submitLocationUseCase =
        ref.read(submitLocationAnswerUseCaseProvider); //Add this back

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
                if (widget.quest.id == null) {
                  //add null check
                  _showError(
                      context,
                      UnexpectedFailure(
                          message:
                              'Quest ID is null.  Cannot submit location.'));
                  return;
                }
                if (_currentPosition == null) {
                  _showError(
                      context,
                      UnexpectedFailure(
                          message:
                              'Current position is null.  Cannot submit location.'));
                  return;
                }
                final resultFuture = submitLocationUseCase(
                  SubmitLocationAnswerParams(
                    questId: widget.quest.id ?? '',
                    latitude: _currentPosition!.latitude,
                    longitude: _currentPosition!.longitude,
                  ),
                ); // Store the Future
                final result = await resultFuture; // Await it
                result.fold(
                  (failure) => _showError(context, failure),
                  (success) => _showSuccess(context), //  use the result of fold
                );
              } catch (e) {
                _showError(
                    context,
                    UnexpectedFailure(
                        message:
                            'Unexpected error: $e')); // Wrap in UnexpectedFailure
              }
            },
            child: const Text('Submit Location'),
          ),
      ],
    );
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

// class LocationCheckInQuestAdapter extends q.Quest {  // Removed Adapter
//  final q.Quest _quest;
//
//  LocationCheckInQuestAdapter(this._quest)
//      : super(
//          id: _quest.id,
//          type: _quest.type,
//          title: _quest.title,
//          description: _quest.description,
//          question: _quest.question,
//          options: _quest.options,
//          correctAnswer: _quest.correctAnswer,
//          locationName: _quest.locationName, // Pass locationName
//          latitude: _quest.latitude,
//          longitude: _quest.longitude,
//          photoTheme: _quest.photoTheme,
//          timeLimitSeconds: _quest.timeLimitSeconds,
//          startTime: _quest.startTime,
//        );
//  // Adapt any other properties needed by LocationCheckInQuestWidget
//}
