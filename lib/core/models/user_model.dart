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
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      avatarUrl: (json['avatarUrl'] ?? json['avatarUrl']) as String?,
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
