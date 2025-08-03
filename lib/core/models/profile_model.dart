class ProfileModel {
  final String avatarUrl;
  final String username;
  final String bio;
  final String followers;
  final String following;

  ProfileModel({
    required this.avatarUrl,
    required this.username,
    required this.bio,
    required this.followers,
    required this.following,
  });

  ProfileModel copyWith({
    String? avatarUrl,
    String? username,
    String? bio,
    String? followers,
    String? following,
  }) {
    return ProfileModel(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}
