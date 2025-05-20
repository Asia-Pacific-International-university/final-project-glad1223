import 'package:image_picker/image_picker.dart';
import '../error/failures.dart'; // Assuming Failure is defined here

class CameraService {
  final ImagePicker _imagePicker;

  CameraService({required ImagePicker imagePicker})
      : _imagePicker = imagePicker;

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);
      return pickedFile;
    } catch (e) {
      // Handle potential errors like permission denied, camera not available
      throw CameraFailure('Failed to pick image from $source: ${e.toString()}');
    }
  }

  Future<XFile?> pickVideo(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(source: source);
      return pickedFile;
    } catch (e) {
      throw CameraFailure('Failed to pick video from $source: ${e.toString()}');
    }
  }
}

class CameraFailure extends Failure {
  const CameraFailure(String message) : super(message: message);
}
