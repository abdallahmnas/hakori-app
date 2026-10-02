import 'package:image_picker/image_picker.dart';

/// Reusable service wrapping [ImagePicker] to keep image selection logic
/// out of the View layer. Returns [XFile?] — null on cancellation.
///
/// Platform-specific setup required:
///
/// **Android** (`android/app/src/main/AndroidManifest.xml`):
/// ```xml
/// <uses-permission android:name="android.permission.CAMERA" />
/// <uses-feature android:name="android.hardware.camera" android:required="false" />
/// ```
///
/// **iOS** (`ios/Runner/Info.plist`):
/// ```xml
/// <key>NSCameraUsageDescription</key>
/// <string>This app needs camera access to take profile photos.</string>
/// <key>NSPhotoLibraryUsageDescription</key>
/// <string>This app needs photo library access to select profile images.</string>
/// ```
class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Pick an image from the device gallery.
  /// Returns null if the user cancels the selection.
  Future<XFile?> pickFromGallery({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth ?? 1024,
        maxHeight: maxHeight ?? 1024,
        imageQuality: imageQuality ?? 85,
      );
      return image;
    } catch (e) {
      // Log or handle specific platform exceptions if needed.
      return null;
    }
  }

  /// Capture an image using the device camera.
  /// Returns null if the user cancels or the camera is unavailable.
  Future<XFile?> pickFromCamera({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCamera = CameraDevice.rear,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth ?? 1024,
        maxHeight: maxHeight ?? 1024,
        imageQuality: imageQuality ?? 85,
        preferredCameraDevice: preferredCamera,
      );
      return image;
    } catch (e) {
      // Log or handle specific platform exceptions if needed.
      return null;
    }
  }
}
