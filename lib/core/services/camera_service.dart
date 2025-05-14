import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    return pickedFile;
  }
}
