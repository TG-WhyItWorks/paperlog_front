import 'package:flutter/material.dart';
import '../../../core/models/review_models.dart';

import '../service/blog_service.dart';

enum BlogSearchFilter { all, title, user }

class BlogSearchViewModel extends ChangeNotifier {
  final _svc = BlogService();
  bool loading = false;
  String? error;
  String keyword = '';
  bool orderByVotes = false;
  BlogSearchFilter filter = BlogSearchFilter.all;
  List<BlogReviewSummary> results = [];

  void setKeyword(String v) {
    keyword = v;
    notifyListeners();
  }

  void setFilter(BlogSearchFilter f) {
    filter = f;
    notifyListeners();
  }

  void setOrderByVotes(bool v) {
    orderByVotes = v;
    notifyListeners();
  }

  Future<void> search() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      if (filter == BlogSearchFilter.title) {
        results = await _svc.searchByTitle(keyword);
      } else if (filter == BlogSearchFilter.user) {
        results = await _svc.searchByUser(keyword);
      } else {
        results = await _svc.searchAll(keyword, orderByVotes: orderByVotes);
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
