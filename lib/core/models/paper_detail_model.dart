// lib/core/models/paper_detail_model.dart
import 'package:intl/intl.dart';
import 'review_models.dart';

String _normalizeAbstract(String raw) {
  if (raw.trim().isEmpty) return '';
  var t = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  // 앞뒤 공백이 낀 단일 개행을 공백으로
  t = t.replaceAll(RegExp(r'[ \t]*\n[ \t]*(?!\n)'), ' ');
  // 3개 이상 연속 개행은 문단 개행 2개로 축약
  t = t.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  // 중복 공백/탭 축약
  t = t.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
  return t.trim();
}

class PaperDetail {
  final String id; // arxiv_id
  final String title;
  final List<String> authors;
  final String year; // "YYYY"
  final List<String> fields; // categories
  final String abstractText; // summary/abstract
  final String translatedAbstract;
  final String blogSummary;
  final String pdfUrl; // link
  final List<BlogReviewSummary> relatedBlogs;

  // 선택: 응답에 있을 수 있는 필드들
  final String? doi;
  final int likeCount;
  final bool? isLiked;

  // 논문 상세 모델
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
      if (v is String && v.trim().isNotEmpty) {
        return v
            .split(RegExp(r'\s*,\s*|\s+and\s+'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
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
    final reviewsRaw = (json['reviews'] is List)
        ? (json['reviews'] as List)
        : const [];
    final related = reviewsRaw
        .whereType<Map>()
        .map((e) => BlogReviewSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return PaperDetail(
      id: _s(json['arxiv_id'] ?? json['id']),
      title: _s(json['title']),
      authors: _ls(json['authors']),
      year: year,
      fields: _ls(json['categories'] ?? json['tags']),
      pdfUrl: _s(json['link'] ?? json['pdfUrl'] ?? json['pdf_url']),
      abstractText: _normalizeAbstract(_s(json['summary'] ?? json['abstract'])),
      translatedAbstract: _s(json['translated_abstract'], '번역된 초록이 여기에 표시됩니다.'),
      blogSummary: _s(json['blog_summary'], '블로그 요약이 여기에 표시됩니다.'),
      relatedBlogs: related,
      doi: json['doi'] == null ? null : json['doi'].toString(),
      likeCount: _i(json['like_count']),
      isLiked: json['is_liked'] is bool ? json['is_liked'] as bool : null,
    );
  }
}
