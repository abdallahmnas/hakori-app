import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profile_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/image_picker_service.dart';

/// Presenter for the Profile feature.
/// Manages profile state and image selection through [ImagePickerService].
class ProfilePresenter extends ChangeNotifier {
  final ImagePickerService _imagePickerService;

  ProfilePresenter(this._imagePickerService);

  ProfileModel _profile = ProfileModel(
    userName: AppConstants.defaultUserName,
    bio: 'Tap to update your profile information.',
  );

  bool _isLoading = false;
  String? _errorMessage;

  // Exposed state
  ProfileModel get profile => _profile;
  String get userName => _profile.userName;
  String? get profileImagePath => _profile.profileImagePath;
  String? get bio => _profile.bio;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasProfileImage => _profile.profileImagePath != null;

  /// Pick a profile image from the given [source].
  Future<void> pickProfileImage(ImageSource source) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final XFile? image;
      if (source == ImageSource.gallery) {
        image = await _imagePickerService.pickFromGallery();
      } else {
        image = await _imagePickerService.pickFromCamera();
      }

      if (image != null) {
        _profile = _profile.copyWith(profileImagePath: image.path);
      }
      // If image is null, user cancelled — do nothing.
    } catch (e) {
      _errorMessage = 'Failed to pick image. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update the user's display name.
  void updateUserName(String name) {
    if (name.trim().isEmpty) return;
    _profile = _profile.copyWith(userName: name.trim());
    notifyListeners();
  }

  /// Update the user's bio.
  void updateBio(String bio) {
    _profile = _profile.copyWith(bio: bio.trim());
    notifyListeners();
  }

  /// Remove the current profile image.
  void removeProfileImage() {
    _profile = _profile.copyWith(clearImage: true);
    notifyListeners();
  }

  /// Clear any error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
