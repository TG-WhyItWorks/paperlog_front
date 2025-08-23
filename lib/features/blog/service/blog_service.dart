// lib/features/blog/service/blog_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/services/token_storage.dart';
import '../../../core/models/review_models.dart';

enum ReviewSearchMode { all, voteOrder, title, content, user }

class BlogService {
  final _token = TokenStorage();

  // Accept만 공통으로; ApiConfig.baseHeaders(json: ..) 그대로 활용
  Map<String, String> _baseHeaders({bool json = true}) => {
    ...ApiConfig.baseHeaders(json: json),
    'Accept': 'application/json',
  };

  // 멀티파트에선 json=false로 넘겨 Content-Type 강제 세팅을 피함
  Future<Map<String, String>> _authHeaders({bool json = true}) async {
    final at = await _token.readAccessToken();
    final h = _baseHeaders(json: json);
    return (at == null || at.isEmpty)
        ? h
        : {...h, 'Authorization': 'Bearer $at'};
  }

  /// 엔드포인트 매핑 (백엔드 라우터에 정확히 맞춤)
  String _pathFor(ReviewSearchMode mode) {
    switch (mode) {
      case ReviewSearchMode.all:
        return '/api/review/search';
      case ReviewSearchMode.voteOrder:
        return '/api/review/search_voteorder';
      case ReviewSearchMode.title:
        return '/api/review/search/title';
      case ReviewSearchMode.content:
        // 백엔드가 "content"가 아니라 "cotent"로 되어 있음
        return '/api/review/search/cotent';
      case ReviewSearchMode.user:
        return '/api/review/search/review/user';
    }
  }

  // === 리스트/검색 ===
  Future<List<BlogReviewSummary>> myReviews() async {
    final uri = ApiConfig.uri('/api/review/my/reviews');
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('내 리뷰 조회 실패: ${res.statusCode}');
    final list = json.decode(res.body) as List;
    return list
        .map((e) => BlogReviewSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<BlogReviewSummary>> searchAll(
    String keyword, {
    int skip = 0,
    int limit = 10,
    bool orderByVotes = false,
  }) async {
    final path = orderByVotes
        ? '/api/review/search_voteorder'
        : '/api/review/search';
    final uri = ApiConfig.uri(path, {
      'keyword': keyword,
      'skip': '$skip',
      'limit': '$limit',
    });
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('검색 실패: ${res.statusCode}');
    final list = json.decode(res.body) as List;
    return list
        .map((e) => BlogReviewSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<BlogReviewSummary>> searchByTitle(
    String keyword, {
    int skip = 0,
    int limit = 10,
  }) async {
    final uri = ApiConfig.uri('/api/review/search/title', {
      'keyword': keyword,
      'skip': '$skip',
      'limit': '$limit',
    });
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('제목 검색 실패: ${res.statusCode}');
    final list = json.decode(res.body) as List;
    return list
        .map((e) => BlogReviewSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<BlogReviewSummary>> searchByUser(
    String keyword, {
    int skip = 0,
    int limit = 10,
  }) async {
    final uri = ApiConfig.uri('/api/review/search/review/user', {
      'keyword': keyword,
      'skip': '$skip',
      'limit': '$limit',
    });
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('유저 검색 실패: ${res.statusCode}');
    final list = json.decode(res.body) as List;
    return list
        .map((e) => BlogReviewSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// 최신 포스트 (페이지네이션)
  Future<List<BlogReviewSummary>> latest({
    int page = 1,
    int pageSize = 20,
  }) async {
    final uri = ApiConfig.uri('/api/review', {
      'page': '$page',
      'page_size': '$pageSize',
    });
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('최신 리뷰 조회 실패: ${res.statusCode}');
    }
    final list = json.decode(res.body) as List;
    return list
        .map((e) => BlogReviewSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// 인기(좋아요순) – keyword 비워두면 전체 인기
  Future<List<BlogReviewSummary>> trending({
    String keyword = '',
    int skip = 0,
    int limit = 10,
  }) async {
    final uri = ApiConfig.uri('/api/review/search_voteorder', {
      'keyword': keyword,
      'skip': '$skip',
      'limit': '$limit',
    });
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('인기 리뷰 조회 실패: ${res.statusCode}');
    }
    final list = json.decode(res.body) as List;
    return list
        .map((e) => BlogReviewSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // 내용 검색
  Future<List<BlogReviewSummary>> searchByContent(
    String keyword, {
    int skip = 0,
    int limit = 10,
  }) async {
    final uri = ApiConfig.uri('/api/review/search/cotent', {
      'keyword': keyword,
      'skip': '$skip',
      'limit': '$limit',
    });
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('내용 검색 실패: ${res.statusCode}');
    final list = json.decode(res.body) as List;
    return list
        .map((e) => BlogReviewSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // 모드 공통 검색
  Future<List<BlogReviewSummary>> search({
    required String keyword,
    required ReviewSearchMode mode,
    int skip = 0,
    int limit = 10,
  }) async {
    final path = _pathFor(mode);
    final uri = ApiConfig.uri(path, {
      'keyword': keyword,
      'skip': '$skip',
      'limit': '$limit',
    });
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('검색 실패: HTTP ${res.statusCode} ${res.body}');
    }
    final list = json.decode(res.body) as List;
    return list
        .map((e) => BlogReviewSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<BlogReviewSummary>> listByPaper(int paperId) async {
    final uri = ApiConfig.uri('/api/review/list/paper/$paperId');
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('논문 리뷰 리스트 실패: ${res.statusCode}');
    }
    final list = json.decode(res.body) as List;
    return list
        .map((e) => BlogReviewSummary.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // === 상세 ===
  Future<BlogReview> detail(int id) async {
    final uri = ApiConfig.uri('/api/review/detail/$id');
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('리뷰 상세 실패: ${res.statusCode}');
    final map = json.decode(res.body) as Map<String, dynamic>;
    return BlogReview.fromJson(map);
  }

  // === 생성/수정/삭제 ===
  Future<void> create({
    required String title,
    required String content,
    int? paperId,
    List<({String name, List<int> bytes})> images = const [],
  }) async {
    final uri = ApiConfig.uri('/api/review/create');
    final req = http.MultipartRequest('POST', uri);
    // 멀티파트: json 헤더 넣지 않음
    final headers = await _authHeaders(json: false);
    req.headers.addAll(headers);
    req.fields['title'] = title;
    req.fields['content'] = content;
    if (paperId != null) req.fields['paper_id'] = paperId.toString();
    for (final f in images) {
      req.files.add(
        http.MultipartFile.fromBytes('images', f.bytes, filename: f.name),
      );
    }
    final streamed = await req.send().timeout(const Duration(seconds: 30));
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('리뷰 작성 실패: HTTP ${res.statusCode} ${res.body}');
    }
  }

  Future<void> update({
    required int reviewId,
    required String title,
    required String content,
    int? paperId,
  }) async {
    final uri = ApiConfig.uri('/api/review/update');
    final body = json.encode({
      'review_id': reviewId,
      'title': title,
      'content': content,
      'paper_id': paperId,
    });
    final res = await http
        .put(uri, headers: await _authHeaders(), body: body)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('리뷰 수정 실패: ${res.statusCode}');
  }

  Future<void> delete(int reviewId) async {
    final uri = ApiConfig.uri('/api/review/delete');
    final body = json.encode({'review_id': reviewId});
    final res = await http
        .delete(uri, headers: await _authHeaders(), body: body)
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('리뷰 삭제 실패: ${res.statusCode}');
    }
  }

  // === 좋아요 ===
  Future<int> like(int reviewId) async {
    final uri = ApiConfig.uri('/api/review/vote/$reviewId');
    final res = await http
        .post(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw Exception('좋아요 실패: ${res.statusCode}');
    }
    return voteCount(reviewId);
  }

  Future<int> unlike(int reviewId) async {
    final uri = ApiConfig.uri('/api/review/reviews/$reviewId/like');
    final res = await http
        .delete(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('좋아요 취소 실패: ${res.statusCode}');
    final map = json.decode(res.body) as Map<String, dynamic>;
    return (map['vote_count'] is int)
        ? map['vote_count'] as int
        : int.tryParse('${map['vote_count'] ?? 0}') ?? 0;
  }

  Future<int> voteCount(int reviewId) async {
    final uri = ApiConfig.uri('/api/review/vote_count/$reviewId');
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('좋아요 수 조회 실패: ${res.statusCode}');
    }
    final map = json.decode(res.body) as Map<String, dynamic>;
    return (map['vote_count'] is int)
        ? map['vote_count'] as int
        : int.tryParse('${map['vote_count'] ?? 0}') ?? 0;
  }

  Future<List<int>> likedReviewIds() async {
    final uri = ApiConfig.uri('/api/review/liked-reviews');
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('좋아요한 리뷰 조회 실패: ${res.statusCode}');
    }
    final list = json.decode(res.body) as List;
    return list.map((e) => (e as Map<String, dynamic>)['id'] as int).toList();
  }

  // 댓글 등록
  Future<void> createComment({
    required int reviewId,
    required String content,
  }) async {
    final uri = ApiConfig.uri('/api/comment/create/$reviewId');
    final res = await http
        .post(
          uri,
          headers: await _authHeaders(),
          body: json.encode({'content': content}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('댓글 등록 실패: HTTP ${res.statusCode} ${res.body}');
    }
  }

  // 특정 리뷰의 댓글 목록
  Future<List<BlogComment>> listComments(int reviewId) async {
    final uri = ApiConfig.uri('/api/comment/review/$reviewId/comments');
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('댓글 목록 조회 실패: HTTP ${res.statusCode} ${res.body}');
    }
    final list = json.decode(res.body) as List;
    return list
        .map((e) => BlogComment.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
