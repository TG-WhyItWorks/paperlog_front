import 'package:flutter/foundation.dart';

class BlogPost {
  /// 선택값: 서버가 안 주면 빈 문자열로 세팅
  final String id;

  /// 필수처럼 쓰지만 서버가 비워줄 수도 있으므로 기본값 제공
  final String title;
  final String url; // 빈 문자열 허용
  final String excerpt; // 요약(없으면 '')

  /// 이미지 URL (nullable)
  final String? imageUrl;

  /// 추가 메타
  final String? source; // 예: 'OpenAI Blog', 'arXiv Insights'
  final DateTime? publishedAt;
  final List<String> tags;

  const BlogPost({
    this.id = '',
    required this.title,
    required this.url,
    required this.excerpt,
    this.imageUrl,
    this.source,
    this.publishedAt,
    this.tags = const <String>[],
  });

  /// JSON → Model (여러 키 변형을 모두 수용)
  factory BlogPost.fromJson(Map<String, dynamic> json) {
    String _s(dynamic v, [String fb = '']) => (v == null) ? fb : v.toString();

    String? _optS(dynamic v) => v == null ? null : v.toString();

    List<String> _stringList(dynamic v) {
      if (v == null) return const <String>[];
      if (v is List) {
        return v
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      }
      // 문자열 하나가 오면 쉼표/공백 기준으로 분해
      if (v is String) {
        final s = v.trim();
        if (s.isEmpty) return const <String>[];
        return s
            .split(RegExp(r'\s*,\s*|\s+'))
            .where((e) => e.isNotEmpty)
            .toList();
      }
      // 그 외 단일 값은 1개짜리 리스트로 흡수
      return [_s(v)].where((e) => e.isNotEmpty).toList();
    }

    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      // 숫자면 epoch(S/millis) 추정
      if (v is num) {
        final n = v.toInt();
        // 10자리면 seconds, 13자리면 millis 정도로 가정
        if (n > 1000000000000) {
          return DateTime.fromMillisecondsSinceEpoch(n, isUtc: true);
        } else if (n > 1000000000) {
          return DateTime.fromMillisecondsSinceEpoch(n * 1000, isUtc: true);
        }
      }
      // 문자열은 ISO8601 시도
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      try {
        return DateTime.parse(s).toUtc();
      } catch (_) {
        return null;
      }
    }

    // 다양한 키 케이스 흡수
    final id = _s(json['id'] ?? json['_id'] ?? json['uuid'], '');
    final title = _s(json['title'], 'Blog');
    final url = _s(json['url'] ?? json['link'], '');
    String excerpt = _s(
      json['excerpt'] ?? json['summary'] ?? json['description'],
      '',
    );
    // excerpt 비어있으면 abstract/content/body에서 자동 생성
    if (excerpt.isEmpty) {
      final content = _s(
        json['abstract'] ?? json['content'] ?? json['body'],
        '',
      );
      if (content.isNotEmpty) {
        final compact = content.replaceAll(RegExp(r'\s+'), ' ').trim();
        excerpt = compact.length > 220
            ? '${compact.substring(0, 220)}…'
            : compact;
      }
    }
    final imageUrl = _optS(
      json['imageUrl'] ??
          json['image_url'] ??
          json['image'] ??
          json['thumbnail'],
    );
    final source = _optS(json['source'] ?? json['site'] ?? json['publisher']);
    final publishedAt = _parseDate(
      json['publishedAt'] ??
          json['published_at'] ??
          json['date'] ??
          json['created_at'],
    );
    final tags = _stringList(
      json['tags'] ?? json['categories'] ?? json['topics'],
    );

    return BlogPost(
      id: id,
      title: title,
      url: url,
      excerpt: excerpt,
      imageUrl: imageUrl,
      source: source,
      publishedAt: publishedAt,
      tags: tags,
    );
  }

  /// 어떤 형태(Map/List/String)든 안전하게 모델로 변환
  factory BlogPost.fromAny(dynamic any) {
    if (any is Map) {
      return BlogPost.fromJson(any.cast<String, dynamic>());
    }
    if (any is List) {
      // 행(row) 배열 같은 형태를 단순 휴리스틱으로 해석
      String? url;
      String title = '';
      String excerpt = '';
      for (final v in any) {
        final s = v?.toString() ?? '';
        if (s.startsWith('http') && url == null) {
          url = s;
          continue;
        }
        if (s.length > title.length) {
          excerpt = title;
          title = s;
        } else if (s.length > excerpt.length) {
          excerpt = s;
        }
      }
      url ??= '';
      if (title.isEmpty) title = 'Blog';
      return BlogPost(id: '', title: title, url: url, excerpt: excerpt);
    }
    if (any is String) {
      return BlogPost(id: '', title: any, url: '', excerpt: '');
    }
    throw ArgumentError('Unsupported item type: ${any.runtimeType}');
  }

  /// 최상위가 List 또는 {items|data|results|list|content: [...]}여도 리스트로 변환
  static List<BlogPost> listFromDynamic(dynamic d) {
    List<dynamic> list;
    if (d is List) {
      list = d;
    } else if (d is Map) {
      for (final k in const ['items', 'data', 'results', 'list', 'content']) {
        final v = d[k];
        if (v is List) {
          list = v;
          return list.map((e) => BlogPost.fromAny(e)).toList();
        }
      }
      // Map인데 컬렉션 키가 없으면 단일 객체로 간주
      return [BlogPost.fromAny(d)];
    } else {
      return const <BlogPost>[];
    }
    return list.map((e) => BlogPost.fromAny(e)).toList();
  }

  /// Model → JSON (snake_case 중심으로 직렬화)
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'url': url,
    'excerpt': excerpt,
    'image_url': imageUrl,
    'source': source,
    'published_at': publishedAt?.toIso8601String(),
    'tags': tags,
  };

  BlogPost copyWith({
    String? id,
    String? title,
    String? url,
    String? excerpt,
    String? imageUrl,
    String? source,
    DateTime? publishedAt,
    List<String>? tags,
  }) {
    return BlogPost(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      excerpt: excerpt ?? this.excerpt,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
      tags: tags ?? this.tags,
    );
  }

  @override
  String toString() => 'BlogPost(id: $id, title: $title)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlogPost &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          url == other.url &&
          excerpt == other.excerpt &&
          imageUrl == other.imageUrl &&
          source == other.source &&
          publishedAt == other.publishedAt &&
          listEquals(tags, other.tags);

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      url.hashCode ^
      excerpt.hashCode ^
      imageUrl.hashCode ^
      source.hashCode ^
      publishedAt.hashCode ^
      tags.hashCode;
}
