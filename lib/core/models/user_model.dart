class UserModel {
  final int id;
  final String username;
  final String email;
  final String? avatarUrl;

  //인증 사용자
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final avatar =
        (json['avatarUrl'] ??
                json['avatar_url'] ??
                json['avatar'] ??
                json['profileImage'] ??
                json['profile_image'])
            as String?;
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: avatar,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}
