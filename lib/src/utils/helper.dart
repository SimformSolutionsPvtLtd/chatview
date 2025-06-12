import 'package:chatview/chatview.dart';
import 'package:image_picker/image_picker.dart';

Future<String?> onMediaActionButtonPressed(
  ImageSource source, {
  ImagePickerConfiguration? config,
}) async {
  try {
    final XFile? image = await ImagePicker().pickImage(
      source: source,
      maxHeight: config?.maxHeight,
      maxWidth: config?.maxWidth,
      imageQuality: config?.imageQuality,
      preferredCameraDevice: config?.preferredCameraDevice ?? CameraDevice.rear,
    );
    final imagePath = await config?.onImagePicked?.call(image?.path);
    return imagePath ?? image?.path;
  } catch (e) {
    return null;
  }
}
