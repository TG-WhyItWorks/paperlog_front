import 'package:flutter/material.dart';
import '../../../core/models/paper_model.dart';
import '../service/paper_recommend_service.dart';

class RecommendedPapersViewModel extends ChangeNotifier {
  final _svc = PaperRecommendService();

  bool loading = false;
  String? error;
  List<Paper> items = const [];

  Future<void> load(String category, {int limit = 3}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _svc.topByCategory(category, limit: limit);
    } catch (e) {
      error = e.toString();
      items = const [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
