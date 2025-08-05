class ProfileModel {
  final String avatarUrl;
  final String username;
  final String bio;
  final String subtitle;
  final int followers;
  final int following;

  ProfileModel({
    required this.avatarUrl,
    required this.username,
    required this.bio,
    required this.subtitle,
    required this.followers,
    required this.following,
  });

  ProfileModel copyWith({
    String? avatarUrl,
    String? username,
    String? bio,
    String? subtitle,
    int? followers,
    int? following,
  }) {
    return ProfileModel(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      subtitle:
          subtitle ?? this.subtitle, // Assuming subtitle is not being changed
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }
}
