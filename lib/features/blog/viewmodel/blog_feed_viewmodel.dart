import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';

import '../service/blog_service.dart';

class BlogFeedViewModel extends ChangeNotifier {
  final _svc = BlogService();
  bool loading = false;
  String? error;
  List<BlogReviewSummary> items = [];

  Future<void> loadMine() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _svc.myReviews();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReview(int reviewId) async {
    final backup = List.of(items);
    items.removeWhere((e) => e.id == reviewId);
    notifyListeners();

    try {
      await _svc.delete(reviewId);
    } catch (e) {
      items = backup;
      error = '삭제 실패: $e';
      notifyListeners();
      rethrow;
    }
  }

  // (선택) 상세에서 pop 결과로 리스트에서만 지울 때 씀
  void removeById(int reviewId) {
    items.removeWhere((e) => e.id == reviewId);
    notifyListeners();
  }
}
