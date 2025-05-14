import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/core/services/camera_service.dart'; // Import CameraService
import 'package:image_picker/image_picker.dart'; // You'll need this package
import 'dart:io';
import 'package:final_project/domain/repositories/quest_repository.dart'; // Corrected import
import 'package:final_project/core/usecases/usecase.dart'; // Import usecase.dart
import 'package:dartz/dartz.dart'; // Import Either
import 'package:final_project/core/error/failures.dart'; // Import Failure

// Define the SubmitPhotoAnswerParams and UseCase
class SubmitPhotoAnswerParams {
  final String questId;
  final String imagePath;

  SubmitPhotoAnswerParams({required this.questId, required this.imagePath});
}

class SubmitPhotoAnswerUseCase
    implements ParamFutureUseCase<SubmitPhotoAnswerParams, void> {
  // Implement ParamFutureUseCase
  final QuestRepository _questRepository;

  SubmitPhotoAnswerUseCase(
      {required QuestRepository questRepository}) // Corrected constructor
      : _questRepository = questRepository;

  @override
  Future<Either<Failure, void>> call(SubmitPhotoAnswerParams params) async {
    // Use call and Either
    // Assuming uploadPhoto returns Future<Either<Failure, void>>
    return await _questRepository.uploadPhoto(params.questId, params.imagePath);
  }
}

// QuestRepository provider (ensure this is defined correctly)
final questRepositoryProvider = Provider<QuestRepository>((ref) {
  throw UnimplementedError(); // Implement this provider
});

final submitPhotoAnswerUseCaseProvider = Provider<SubmitPhotoAnswerUseCase>(
  (ref) => SubmitPhotoAnswerUseCase(
    questRepository: ref.read(questRepositoryProvider),
  ),
);

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
  Widget build(BuildContext context, WidgetRef ref) {
    final submitPhoto = ref.read(submitPhotoAnswerUseCaseProvider);

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
                final result = await submitPhoto.call(
                  // Use call()
                  SubmitPhotoAnswerParams(
                      questId:
                          widget.quest.id!, // Use null assertion or handle null
                      imagePath: _pickedImage!.path),
                );
                result.fold(
                  (failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${failure.message}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Photo submitted!')),
                    );
                    setState(() {
                      _pickedImage = null; // Clear image after submission
                    });
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please take a photo first.')),
                );
              }
            },
            child: const Text('Submit Photo'),
          ),
        ],
      ],
    );
  }
}

// Ensure you have a CameraService provider defined, e.g.:
final cameraServiceProvider = Provider<CameraService>((ref) => CameraService());
