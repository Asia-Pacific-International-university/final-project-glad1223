import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dartz/dartz.dart';
//import 'package:final_project/core/error/failures.dart'; // Import Failure
//import 'package:final_project/core/usecases/usecase.dart'; // Import UseCase

// 1. Domain Entity (Simplified for this example)
class Quest {
  final String? id;
  // Add other relevant quest properties
  Quest({this.id});
}

// 2. Failure Class (Ensure this is consistent)
abstract class Failure {
  final String message;
  Failure({required this.message});
}

class ServerFailure extends Failure {
  ServerFailure({String? message = 'Server error'})
      : super(message: message ?? 'Server error');
}

class CacheFailure extends Failure {
  CacheFailure({String? message = 'Cache error'})
      : super(message: message ?? 'Cache error');
}

class UnexpectedFailure extends Failure {
  UnexpectedFailure({String? message = 'Unexpected error'})
      : super(message: message ?? 'Unexpected error');
}

// 3. UseCase Interface
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// 4.  ParamFutureUseCase Interface
abstract class ParamFutureUseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// 5. Define Parameters Class
class SubmitPhotoAnswerParams {
  final String questId;
  final String imagePath;

  SubmitPhotoAnswerParams({required this.questId, required this.imagePath});
}

// 6. Define UseCase
class SubmitPhotoAnswerUseCase
    implements UseCase<void, SubmitPhotoAnswerParams> {
  final QuestRepository _questRepository;

  SubmitPhotoAnswerUseCase({required QuestRepository questRepository})
      : _questRepository = questRepository;

  @override
  Future<Either<Failure, void>> call(SubmitPhotoAnswerParams params) async {
    try {
      // Call the repository's uploadPhoto method
      await _questRepository.uploadPhoto(params.questId, params.imagePath);
      return const Right(null); // Indicate success
    } on Failure catch (failure) {
      //convert to Failure
      return Left(failure);
    } catch (e) {
      return Left(UnexpectedFailure(
          message: 'An unexpected error occurred: $e')); // Handle other errors
    }
  }
}

// 7. Abstract Repository
abstract class QuestRepository {
  Future<void> uploadPhoto(String questId, String imagePath);
  // Add other repository methods as needed
}

// 8.  *Mock* Repository Implementation (for testing)
class MockQuestRepository implements QuestRepository {
  @override
  Future<void> uploadPhoto(String questId, String imagePath) async {
    // Simulate a successful upload
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simulate network delay

    // In a real implementation, you'd handle actual upload logic and potential errors
    //  (e.g., using try-catch and returning Left(Failure) on error).

    if (imagePath.contains('error')) {
      //Simulate error
      throw ServerFailure(message: "Simulated server error during upload");
    }
    return Future.value(); // Return a completed Future<void> for success
  }
}

// 9. Camera Service (Simplified for this example)
class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    return pickedFile;
  }
}

// 10.  Providers
final cameraServiceProvider = Provider<CameraService>((ref) => CameraService());

// Use the MockQuestRepository here.  In your real app, you'd use your actual implementation.
final questRepositoryProvider =
    Provider<QuestRepository>((ref) => MockQuestRepository());

final submitPhotoAnswerUseCaseProvider = Provider<SubmitPhotoAnswerUseCase>(
  (ref) => SubmitPhotoAnswerUseCase(
    questRepository: ref.read(questRepositoryProvider),
  ),
);

// 11. PhotoChallengeQuestWidget
class PhotoChallengeQuestWidget extends ConsumerStatefulWidget {
  final Quest quest;

  const PhotoChallengeQuestWidget({super.key, required this.quest});

  @override
  ConsumerState<PhotoChallengeQuestWidget> createState() =>
      _PhotoChallengeQuestWidgetState();
}

class _PhotoChallengeQuestWidgetState
    extends ConsumerState<PhotoChallengeQuestWidget> {
  File? _pickedImage;

  Future<void> _pickImage() async {
    final pickedFile =
        await ref.read(cameraServiceProvider).pickImage(ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
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
          onPressed: _pickImage,
          child: const Text('Take Photo'),
        ),
        const SizedBox(height: 16),
        if (_pickedImage != null) ...[
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Image.file(
              _pickedImage!,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_pickedImage != null) {
                final result = await submitPhotoUseCase(
                  SubmitPhotoAnswerParams(
                    questId: widget.quest.id ?? '',
                    imagePath: _pickedImage!.path,
                  ),
                );
                result.fold(
                  (failure) => _showError(context, failure),
                  (success) => _showSuccess(context),
                );
              } else {
                _showInputError(context);
              }
            },
            child: const Text('Submit Photo'),
          ),
        ],
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
      const SnackBar(content: Text('Photo submitted!')),
    );
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
