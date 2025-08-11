// lib/core/models/paper_detail_model.dart
import 'package:intl/intl.dart';

class BlogPost {
  final String title;
  final String excerpt;
  final String url;
  final String? imageUrl;

  BlogPost({
    required this.title,
    required this.excerpt,
    required this.url,
    this.imageUrl,
  });

  factory BlogPost.fromJson(Map<String, dynamic> json) {
    String _s(dynamic v, [String fb = '']) => v?.toString() ?? fb;
    return BlogPost(
      title: _s(json['title'], 'Blog'),
      excerpt: _s(json['excerpt']),
      url: _s(json['url']), // 없으면 '' (빈 문자열)
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
    );
  }
}

class PaperDetail {
  final String id; // arxiv_id
  final String title;
  final List<String> authors;
  final String year; // "YYYY"
  final List<String> fields; // categories
  final String abstractText; // summary/abstract
  final String translatedAbstract; // 기본값 제공
  final String blogSummary; // 기본값 제공
  final String pdfUrl; // link
  final List<BlogPost> relatedBlogs;

  // 선택: 응답에 있을 수 있는 필드들
  final String? doi;
  final int likeCount;
  final bool? isLiked;

  PaperDetail({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.fields,
    required this.abstractText,
    required this.pdfUrl,
    this.translatedAbstract = '번역된 초록이 여기에 표시됩니다.',
    this.blogSummary = '블로그 요약이 여기에 표시됩니다.',
    this.relatedBlogs = const [],
    this.doi,
    this.likeCount = 0,
    this.isLiked,
  });

  factory PaperDetail.fromJson(Map<String, dynamic> json) {
    String _s(dynamic v, [String fb = '']) => v?.toString() ?? fb;

    List<String> _ls(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return const <String>[];
    }

    int _i(dynamic v, [int fb = 0]) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fb;
      return fb;
    }

    // 연도 계산
    final publishedRaw =
        json['published'] ??
        json['publish_updated'] ??
        json['published_at'] ??
        '';
    final dt = DateTime.tryParse(publishedRaw.toString()) ?? DateTime.now();
    final year = DateFormat('yyyy').format(dt);

    // reviews → BlogPost[]
    final reviews = (json['reviews'] is List)
        ? (json['reviews'] as List)
        : const [];
    final blogs = reviews.map((e) {
      if (e is Map<String, dynamic>) return BlogPost.fromJson(e);
      return BlogPost(title: 'Blog', excerpt: '', url: '', imageUrl: null);
    }).toList();

    return PaperDetail(
      id: _s(json['arxiv_id'] ?? json['id']),
      title: _s(json['title']),
      authors: _ls(json['authors']),
      year: year,
      fields: _ls(json['categories'] ?? json['tags']),
      pdfUrl: _s(json['link'] ?? json['pdfUrl'] ?? json['pdf_url']),
      abstractText: _s(json['summary'] ?? json['abstract']),
      translatedAbstract: _s(json['translated_abstract'], '번역된 초록이 여기에 표시됩니다.'),
      blogSummary: _s(json['blog_summary'], '블로그 요약이 여기에 표시됩니다.'),
      relatedBlogs: blogs,
      doi: json['doi'] == null ? null : json['doi'].toString(),
      likeCount: _i(json['like_count']),
      isLiked: json['is_liked'] is bool ? json['is_liked'] as bool : null,
    );
  }
}
