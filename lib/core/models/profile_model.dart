class ProfileModel {
  final String avatarUrl;
  final String username;
  final String bio;
  final String subtitle;
  final int followers;
  final int following;

  //사용자 프로필
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

//관심 통계 모델
class InterestStat {
  final String field;
  final int count;
  const InterestStat({required this.field, required this.count});

  factory InterestStat.fromJson(Map<String, dynamic> json) =>
      InterestStat(field: json['field'] as String, count: json['count'] as int);

  Map<String, dynamic> toJson() => {'field': field, 'count': count};
}

// 업적 뱃지
class BadgeModel {
  final String code;
  final String name;
  final String description;
  final int threshold;
  final bool achieved;
  final DateTime? achievedAt;
  final String? iconAsset;

  const BadgeModel({
    required this.code,
    required this.name,
    required this.description,
    required this.threshold,
    required this.achieved,
    this.achievedAt,
    this.iconAsset,
  });

  BadgeModel copyWith({
    String? code,
    String? name,
    String? description,
    int? threshold,
    bool? achieved,
    DateTime? achievedAt,
    String? iconAsset,
  }) {
    return BadgeModel(
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      threshold: threshold ?? this.threshold,
      achieved: achieved ?? this.achieved,
      achievedAt: achievedAt ?? this.achievedAt,
      iconAsset: iconAsset ?? this.iconAsset,
    );
  }

  factory BadgeModel.fromJson(Map<String, dynamic> json) => BadgeModel(
    code: json['code'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    threshold: json['threshold'] as int,
    achieved: json['achieved'] as bool,
    achievedAt: json['achievedAt'] != null
        ? DateTime.parse(json['achievedAt'] as String)
        : null,
    iconAsset: json['iconAsset'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'description': description,
    'threshold': threshold,
    'achieved': achieved,
    if (achievedAt != null) 'achievedAt': achievedAt!.toIso8601String(),
    if (iconAsset != null) 'iconAsset': iconAsset,
  };
}
