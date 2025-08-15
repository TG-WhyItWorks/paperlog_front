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
}
