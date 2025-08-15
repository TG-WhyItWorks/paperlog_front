class BlogUser {
  final int? id;
  final String username;
  final String? email;
  final String? avatarUrl;

  BlogUser({this.id, required this.username, this.email, this.avatarUrl});

  factory BlogUser.fromJson(Map<String, dynamic> json) {
    String s(dynamic v, [String fb = '']) => v?.toString() ?? fb;
    return BlogUser(
      id: json['id'] as int?,
      username: s(json['username']),
      email: json['email']?.toString(),
      avatarUrl:
          json['avatarUrl']?.toString() ?? json['avatar_url']?.toString(),
    );
  }
}

class ReviewImageRead {
  final int id;
  final String imagePath;
  final DateTime? uploadDate;

  ReviewImageRead({required this.id, required this.imagePath, this.uploadDate});

  factory ReviewImageRead.fromJson(Map<String, dynamic> json) {
    DateTime? _dt(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return ReviewImageRead(
      id: json['id'] as int,
      imagePath: (json['image_path'] ?? json['imagePath'] ?? '').toString(),
      uploadDate: _dt(json['upload_date'] ?? json['uploadDate']),
    );
  }
}

class BlogComment {
  final int? id;
  final String content;
  final BlogUser? user;
  final DateTime? createDate;

  BlogComment({this.id, required this.content, this.user, this.createDate});

  factory BlogComment.fromJson(Map<String, dynamic> json) {
    DateTime? _dt(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return BlogComment(
      id: json['id'] as int?,
      content: (json['content'] ?? '').toString(),
      user: (json['user'] is Map)
          ? BlogUser.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
      createDate: _dt(
        json['create_date'] ?? json['created_at'] ?? json['createAt'],
      ),
    );
  }
}

class BlogReview {
  final int id;
  final String title;
  final String content;
  final DateTime? createDate;
  final DateTime? modifyDate;
  final BlogUser? user;
  final int? paperId;
  final List<ReviewImageRead> images;
  final List<BlogComment> comments;
  final int voteCount;

  BlogReview({
    required this.id,
    required this.title,
    required this.content,
    this.createDate,
    this.modifyDate,
    this.user,
    this.paperId,
    this.images = const [],
    this.comments = const [],
    this.voteCount = 0,
  });

  factory BlogReview.fromJson(Map<String, dynamic> json) {
    DateTime? _dt(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    final imgs = (json['images'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => ReviewImageRead.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final cmts = (json['comment'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => BlogComment.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return BlogReview(
      id: json['id'] as int,
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      createDate: _dt(json['create_date']),
      modifyDate: _dt(json['modify_date']),
      user: (json['user'] is Map)
          ? BlogUser.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
      paperId: json['paper_id'] is int
          ? json['paper_id'] as int
          : int.tryParse('${json['paper_id'] ?? ''}'),
      images: imgs,
      comments: cmts,
      voteCount: (json['vote_count'] is int)
          ? json['vote_count']
          : int.tryParse('${json['vote_count'] ?? 0}') ?? 0,
    );
  }

  BlogReview copyWith({int? voteCount}) {
    return BlogReview(
      id: id,
      title: title,
      content: content,
      createDate: createDate,
      modifyDate: modifyDate,
      user: user,
      paperId: paperId,
      images: images,
      comments: comments,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}

class BlogReviewSummary {
  final int id;
  final String title;
  final String content;
  final DateTime? modifyDate;
  final BlogUser? user;
  final int voteCount;

  BlogReviewSummary({
    required this.id,
    required this.title,
    required this.content,
    this.modifyDate,
    this.user,
    this.voteCount = 0,
  });

  factory BlogReviewSummary.fromJson(Map<String, dynamic> json) {
    DateTime? _dt(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return BlogReviewSummary(
      id: json['id'] as int,
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      modifyDate: _dt(json['modify_date']),
      user: (json['user'] is Map)
          ? BlogUser.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
      voteCount: (json['vote_count'] is int)
          ? json['vote_count']
          : int.tryParse('${json['vote_count'] ?? 0}') ?? 0,
    );
  }
}
