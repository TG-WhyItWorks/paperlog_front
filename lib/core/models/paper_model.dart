import 'package:intl/intl.dart';
import 'review_models.dart';

class Paper {
  final String id;
  final String title;
  final List<String> authors;
  final String year;
  final List<String> fields;
  final String pdfUrl;
  final String abstractText;
  final DateTime? publishedAt;
  final String translatedAbstract;
  final String blogSummary;
  final List<BlogReviewSummary> relatedBlogs;
  final String? doi;
  final int likeCount;
  final bool? isLiked;

  Paper({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.fields,
    required this.pdfUrl,
    required this.abstractText,
    this.publishedAt,
    this.translatedAbstract = '번역된 초록이 여기에 표시됩니다.',
    this.blogSummary = '블로그 요약이 여기에 표시됩니다.',
    this.relatedBlogs = const [],
    this.doi,
    this.likeCount = 0,
    this.isLiked,
  });

  Paper copyWith({
    String? id,
    String? title,
    List<String>? authors,
    String? year,
    List<String>? fields,
    String? pdfUrl,
    String? abstractText,
    DateTime? publishedAt,
    String? translatedAbstract,
    String? blogSummary,
    List<BlogReviewSummary>? relatedBlogs,
    String? doi,
    int? likeCount,
    bool? isLiked,
  }) {
    return Paper(
      id: id ?? this.id,
      title: title ?? this.title,
      authors: authors ?? List<String>.from(this.authors),
      year: year ?? this.year,
      fields: fields ?? List<String>.from(this.fields),
      pdfUrl: pdfUrl ?? this.pdfUrl,
      abstractText: abstractText ?? this.abstractText,
      publishedAt: publishedAt ?? this.publishedAt,
      translatedAbstract: translatedAbstract ?? this.translatedAbstract,
      blogSummary: blogSummary ?? this.blogSummary,
      relatedBlogs:
          relatedBlogs ?? List<BlogReviewSummary>.from(this.relatedBlogs),
      doi: doi ?? this.doi,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  // JSON 변환 메소드
  factory Paper.fromJson(Map<String, dynamic> json) {
    String _s(dynamic v, [String fallback = '']) => v?.toString() ?? fallback;

    List<String> _ls(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String && v.trim().isNotEmpty) {
        // "A, B, C" 또는 "A and B" 형태까지 안전 분리
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

    final raw =
        json['published'] ??
        json['publish_updated'] ??
        json['publishDate'] ??
        json['published_at'] ??
        '';
    DateTime? publishedAt;
    if (raw is String && raw.isNotEmpty) {
      // 예: "2018-04-09T12:00:08"
      publishedAt = DateTime.tryParse(raw);
    } else if (raw is int) {
      // 만약 서버가 epoch seconds/millis로 줄 수도 있으니 방어
      if (raw > 1000000000000) {
        publishedAt = DateTime.fromMillisecondsSinceEpoch(
          raw,
          isUtc: true,
        ).toLocal();
      } else if (raw > 1000000000) {
        publishedAt = DateTime.fromMillisecondsSinceEpoch(
          raw * 1000,
          isUtc: true,
        ).toLocal();
      }
    }
    final year = (publishedAt != null)
        ? DateFormat('yyyy').format(publishedAt)
        : _s(json['year'], ''); // 백호환

    // reviews → BlogReviewSummary[]
    final reviewsRaw = (json['reviews'] is List)
        ? (json['reviews'] as List)
        : const [];
    final related = reviewsRaw
        .whereType<Map>()
        .map((e) => BlogReviewSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return Paper(
      id: _s(json['arxiv_id'] ?? json['id']),
      title: _s(json['title']),
      authors: _ls(json['authors']),
      year: year,
      fields: _ls(json['categories'] ?? json['tags']),
      pdfUrl: _s(json['link'] ?? json['pdfUrl'] ?? json['pdf_url']),
      abstractText: _s(json['summary'] ?? json['abstract']),
      publishedAt: publishedAt,
      doi: (json['doi'] == null) ? null : json['doi'].toString(),
      likeCount: _i(json['like_count']),
      isLiked: (json['is_liked'] is bool) ? json['is_liked'] as bool : null,
      relatedBlogs: related,
    );
  }
}
