class BlogPost {
  final String title;
  final String excerpt;
  final String url;
  final String? imageUrl;

  BlogPost({
    required this.title,
    required this.excerpt,
    required this.url,
    required this.imageUrl,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    return BlogPost(
      title: json['title'] as String,
      excerpt: json['excerpt'] as String,
      url: json['url'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class PaperDetail {
  final String id;
  final String title;
  final List<String> authors;
  final int year;
  final List<String> fields;
  final String abstractText;
  final String translatedAbstract;
  final String blogSummary;
  final String pdfUrl;
  final List<BlogPost> relatedBlogs;

  PaperDetail({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.fields,
    required this.abstractText,
    required this.blogSummary,
    required this.pdfUrl,
    required this.translatedAbstract,
    this.relatedBlogs = const [],
  });

  factory PaperDetail.fromJson(Map<String, dynamic> json) {
    return PaperDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      authors: List<String>.from(json['authors'] as List<dynamic>),
      year: json['year'] as int,
      fields: List<String>.from(json['fields'] as List<dynamic>),
      abstractText: json['abstractText'] as String,
      blogSummary: json['blogSummary'] as String,
      pdfUrl: json['pdfUrl'] as String,
      translatedAbstract: json['translatedAbstract'] as String,
      relatedBlogs:
          (json['relatedBlogs'] as List<dynamic>?)
              ?.map((e) => BlogPost.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
