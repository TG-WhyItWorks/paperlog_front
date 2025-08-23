import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';
import '../../blog/service/blog_service.dart';

class PaperReviewListViewModel extends ChangeNotifier {
  final _svc = BlogService();
  bool loading = false;
  String? error;
  List<BlogReviewSummary> items = [];

  Future<void> loadByPaperTitle(String title, {int limit = 10}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      // 논문 제목으로 좋아요순 검색
      final list = await _svc.searchAll(
        title,
        skip: 0,
        limit: limit,
        orderByVotes: true, // ⭐ 좋아요 많은 순
      );
      // 혹시나 정렬이 안되어 왔을 경우 대비(내림차순)
      list.sort((a, b) => (b.voteCount).compareTo(a.voteCount));
      items = list;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
