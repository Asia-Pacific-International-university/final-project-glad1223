import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:final_project/domain/entities/quest.dart';
import 'package:final_project/core/services/camera_service.dart'; // Import CameraService
import 'package:image_picker/image_picker.dart'; // You'll need this package
import 'dart:io';
import 'package:final_project/domain/repositories/quest_repository.dart';
import 'package:final_project/presentation/providers/quest_provider.dart';

// Define the SubmitPhotoAnswerParams and UseCase
class SubmitPhotoAnswerParams {
  final String questId;
  final String imagePath;

  SubmitPhotoAnswerParams({required this.questId, required this.imagePath});
}

class SubmitPhotoAnswerUseCase
    implements FutureUseCase<void, SubmitPhotoAnswerParams> {
  final QuestRepository _questRepository;

  SubmitPhotoAnswerUseCase({required this.questRepository});

  @override
  Future<void> execute(SubmitPhotoAnswerParams params) async {
    await _questRepository.uploadPhoto(params.questId, params.imagePath);
  }
}

final submitPhotoAnswerUseCaseProvider = Provider<SubmitPhotoAnswerUseCase>(
  (ref) => SubmitPhotoAnswerUseCase(
      questRepository: ref.read(questRepositoryProvider)),
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
              await submitPhoto.execute(
                SubmitPhotoAnswerParams(
                    questId: widget.quest.id, imagePath: _pickedImage!.path),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Photo submitted!')),
              );
              setState(() {
                _pickedImage = null; // Clear image after submission
              });
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
