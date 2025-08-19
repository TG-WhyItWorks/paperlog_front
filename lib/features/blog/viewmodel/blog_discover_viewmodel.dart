import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';
import '../service/blog_service.dart';

class BlogDiscoverViewModel extends ChangeNotifier {
  final _svc = BlogService();

  bool loading = false;
  String? error;

  List<BlogReviewSummary> featured = []; // 캐러셀
  List<BlogReviewSummary> ranking = []; // 랭킹 리스트
  List<BlogReviewSummary> latest = []; // 최신 그리드
  List<BlogReviewSummary> categoryItems = []; // 칩 선택 결과

  String? selectedCategory;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      // 인기 TOP 10 (상위 5는 캐러셀, 나머지 랭킹)
      final top = await _svc.trending(keyword: '', limit: 10);
      featured = top.take(5).toList();
      ranking = top.skip(5).take(10).toList();

      // 최신 12개
      latest = await _svc.latest(page: 1, pageSize: 12);
    } catch (e) {
      error = '$e';
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
      notifyListeners();
    }
  }
}
