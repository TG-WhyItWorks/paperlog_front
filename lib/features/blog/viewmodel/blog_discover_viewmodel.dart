import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';
import '../service/blog_service.dart';

enum MockPreset { generic, tistory }

class BlogDiscoverViewModel extends ChangeNotifier {
  final _svc = BlogService();

  bool loading = false;
  String? error;

  List<BlogReviewSummary> featured = []; // 캐러셀
  List<BlogReviewSummary> ranking = []; // 랭킹 리스트
  List<BlogReviewSummary> latest = []; // 최신 그리드
  List<BlogReviewSummary> categoryItems = []; // 칩 선택 결과

  String? selectedCategory;

  Future<void> load({bool mockOnly = false, bool useMockIfEmpty = true}) async {
    loading = true;
    error = null;
    notifyListeners();
    if (mockOnly) {
      _fillMockAll();
      loading = false;
      notifyListeners();
      return;
    }
    try {
      final top = await _svc.trending(keyword: '', limit: 10);
      featured = top.take(5).toList();
      ranking = top.skip(5).take(10).toList();
      latest = await _svc.latest(page: 1, pageSize: 12);
      if (useMockIfEmpty) _ensureMockIfEmpty();
    } catch (e) {
      // 실패 시에도 화면을 채우기 위해 더미 주입
      error = '$e';
      _ensureMockIfEmpty();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> pickCategory(String kw) async {
    selectedCategory = kw;
    notifyListeners();
    try {
      categoryItems = await _svc.searchAll(kw, limit: 8, orderByVotes: true);
    } catch (e) {
      // 실패해도 앱 죽이지 않음
    } finally {
      if ((categoryItems.isEmpty) && selectedCategory != null) {
        categoryItems = _mockList(count: 8, category: selectedCategory!);
      }
      notifyListeners();
    }
  }

  // ---------- Mock helpers ----------
  void _fillMockAll() {
    featured = _mockList(count: 5, category: 'AI');
    ranking = _mockList(count: 10, category: 'LLM');
    latest = _mockList(count: 12, category: 'NLP');
  }

  void _ensureMockIfEmpty() {
    // 아무것도 없으면 전부 채움
    if (featured.isEmpty && ranking.isEmpty && latest.isEmpty) {
      final all = _mockList(count: 18, category: 'AI');
      featured = all.take(5).toList();
      ranking = all.skip(5).take(10).toList();
      latest = all.skip(15).toList(); // 남은 3개
    } else {
      if (featured.isEmpty) featured = _mockList(count: 5, category: 'AI');
      if (ranking.isEmpty) ranking = _mockList(count: 10, category: 'LLM');
      if (latest.isEmpty) latest = _mockList(count: 12, category: 'NLP');
    }
  }

  List<BlogReviewSummary> _mockList({
    required int count,
    String category = 'AI',
  }) {
    final thumbs = const [
      // https 이미지 (Unsplash/placeholder)
      'https://images.unsplash.com/photo-1542831371-29b0f74f9713?q=80&w=1400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1526378722484-bd91ca387e72?q=80&w=1400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=1400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1555255707-c07966088b7b?q=80&w=1400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1551281044-8c5f6c4f0994?q=80&w=1400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=1400&auto=format&fit=crop',
    ];
    BlogReviewSummary mk(int i) {
      final id = -1000 - i; // 음수 ID로 실제 데이터와 충돌 방지
      final title = '[$category] Mock Post #${i + 1}: A Practical Guide';
      final cover = thumbs[i % thumbs.length];
      final md =
          '![cover]($cover)\n\n'
          '**TL;DR**: 이 포스트는 서비스 프리런치용 더미 데이터입니다.\n\n'
          '- 카테고리: $category\n'
          '- 핵심: 목록/캐러셀/그리드 미리보기 확인용';
      final user = BlogUser(
        id: 9000 + i,
        username: 'Guest ${i + 1}',
        avatarUrl: 'https://i.pravatar.cc/150?img=${(i % 70) + 1}',
      );
      return BlogReviewSummary(
        id: id,
        title: title,
        content: md,
        modifyDate: DateTime.now().subtract(Duration(days: i)),
        user: user,
        voteCount: 7 + (i % 30),
      );
    }

    return List.generate(count, mk);
  }
}
