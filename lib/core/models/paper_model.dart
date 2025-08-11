import 'package:intl/intl.dart';

class Paper {
  final String id;
  final String title;
  final List<String> authors;
  final String year;
  final List<String> fields;
  final String pdfUrl;
  final String abstractText;

  final String translatedAbstract; // 임의의 필드
  final String blogSummary; // 임의의 필드
  final List<dynamic> relatedBlogs; // 타입에 맞게 수정 필요
  final String? doi; // Nullable 타입으로 변경
  final int likeCount;
  final bool? isLiked; // Nullable 타입으로 변경

  Paper({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.fields,
    required this.pdfUrl,
    required this.abstractText,
    this.translatedAbstract = '번역된 초록이 여기에 표시됩니다.', // 기본값 설정
    this.blogSummary = '블로그 요약이 여기에 표시됩니다.', // 기본값 설정
    this.relatedBlogs = const [], // 기본값 설정
    this.doi,
    this.likeCount = 0,
    this.isLiked,
  });

  // Paper copyWith({
  //   String? id,
  //   String? title,
  //   String? summary,
  //   List<String>? tags,
  //   String? recommendationReason,
  //   String? imageUrl,
  // }) {
  //   return Paper(
  //     id: id ?? this.id,
  //     title: title ?? this.title,

  //   );
  // }

  // JSON 변환 메소드
  factory Paper.fromJson(Map<String, dynamic> json) {
    String _s(dynamic v, [String fallback = '']) => v?.toString() ?? fallback;

    List<String> _ls(dynamic v) {
      if (v is List) return v.map((e) => e.toString()).toList();
      return const <String>[];
    }

    int _i(dynamic v, [int fb = 0]) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fb;
      return fb;
    }

    final publishedRaw =
        json['published'] ?? json['publishDate'] ?? json['published_at'] ?? '';
    final publishedDate =
        DateTime.tryParse(publishedRaw.toString()) ?? DateTime.now();
    final year = DateFormat('yyyy').format(publishedDate);

    // reviews → BlogPost 리스트(없으면 빈 리스트)
    final reviews = (json['reviews'] is List)
        ? (json['reviews'] as List)
        : const [];
    final blogs = reviews.map((e) {
      if (e is Map<String, dynamic>) {
        return BlogPost.fromJson(e);
      } else {
        return BlogPost(title: 'Blog', url: '', excerpt: '', imageUrl: null);
      }
    }).toList();

    return Paper(
      id: _s(json['arxiv_id'] ?? json['id']), // 둘 중 있는 걸 사용
      title: _s(json['title']),
      authors: _ls(json['authors']),
      year: year,
      fields: _ls(json['categories'] ?? json['tags']),
      pdfUrl: _s(json['link'] ?? json['pdfUrl'] ?? json['pdf_url']),
      abstractText: _s(json['summary'] ?? json['abstract']),
      doi: (json['doi'] == null) ? null : json['doi'].toString(),
      likeCount: _i(json['like_count']),
      isLiked: (json['is_liked'] is bool) ? json['is_liked'] as bool : null,
      relatedBlogs: (json['reviews'] is List)
          ? json['reviews'] as List
          : const [],
    );
  }

  ///샘플 데이터 반환
  static List<Paper> sampleList() {
    return [
      Paper(
        id: '1706.03762',
        title: 'Attention Is All You Need',
        authors: [
          'Ashish Vaswani',
          'Noam Shazeer',
          'Niki Parmar',
          'Jakob Uszkoreit',
        ],
        year: '2017',
        fields: ['cs.CL', 'cs.LG'],
        pdfUrl: 'http://arxiv.org/abs/1706.03762v5',
        abstractText:
            'The dominant sequence transduction models are based on complex recurrent or convolutional neural networks... We propose a new simple network architecture, the Transformer...',
        doi: '10.48550/arXiv.1706.03762',
        likeCount: 1234,
        isLiked: true,
      ),
      Paper(
        id: '1512.03385',
        title: 'Deep Residual Learning for Image Recognition',
        authors: ['Kaiming He', 'Xiangyu Zhang', 'Shaoqing Ren', 'Jian Sun'],
        year: '2015',
        fields: ['cs.CV'],
        pdfUrl: 'http://arxiv.org/abs/1512.03385v1',
        abstractText:
            'Deeper neural networks are more difficult to train. We present a residual learning framework to ease the training of networks that are substantially deeper than those used previously...',
        doi: '10.1109/CVPR.2016.90',
        likeCount: 987,
        isLiked: false,
      ),
      Paper(
        id: '1409.1556',
        title:
            'Very Deep Convolutional Networks for Large-Scale Image Recognition',
        authors: ['Karen Simonyan', 'Andrew Zisserman'],
        year: '2014',
        fields: ['cs.CV', 'cs.NE'],
        pdfUrl: 'http://arxiv.org/abs/1409.1556v6',
        abstractText:
            'In this work we investigate the effect of the convolutional network depth on its accuracy in the large-scale image recognition setting. Our main contribution is a thorough evaluation of networks of increasing depth...',
        doi: '10.48550/arXiv.1409.1556',
        likeCount: 852,
        isLiked: null, // '좋아요'를 누르지 않은 상태
      ),
    ];
  }
}

class BlogPost {
  final String title;
  final String url; // 빈 문자열 허용 (없을 수 있음)
  final String excerpt;
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
      url: _s(json['url']), // 없으면 ''이 들어감
      excerpt: _s(json['excerpt']),
      imageUrl: json['imageUrl']?.toString() ?? json['image_url']?.toString(),
    );
  }
}
