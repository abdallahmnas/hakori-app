/// Data model for user profile information.
class ProfileModel {
  final String userName;
  final String? profileImagePath;
  final String? bio;

  const ProfileModel({
    required this.userName,
    this.profileImagePath,
    this.bio,
  });

  ProfileModel copyWith({
    String? userName,
    String? profileImagePath,
    String? bio,
    bool clearImage = false,
  }) {
    return ProfileModel(
      userName: userName ?? this.userName,
      profileImagePath:
          clearImage ? null : (profileImagePath ?? this.profileImagePath),
      bio: bio ?? this.bio,
    );
  }
}
