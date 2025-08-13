class BlogPost {
  final String title;
  final String url; // 빈 문자열 허용
  final String excerpt; // N자 요약
  final String? imageUrl;

  BlogPost({
    required this.title,
    required this.url,
    required this.excerpt,
    this.imageUrl,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    String _s(dynamic v, [String fb = '']) => v?.toString() ?? fb;

    return BlogPost(
      title: _s(json['title'], 'Blog'),
      url: _s(json['url']), // 없으면 ''
      excerpt: _s(json['excerpt']),
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
    );
  }
}
