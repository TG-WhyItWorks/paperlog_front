import 'package:flutter/material.dart';
import '../../../core/models/paper_model.dart';
import '../service/arxiv_service.dart';

class ExploreViewmodel extends ChangeNotifier {
  final _service = ArxivService();

  bool isLoading = false;
  String? errorMessage;
  List<Paper> papers = [];
  bool hasSearched = false;

  Future<void> search(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      // 초기 상태 유지
      return;
    }

    hasSearched = true;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      papers = await _service.fetchPapers(q);
      debugPrint('[ARXIV] parsed papers = ${papers.length}');
    } catch (e) {
      debugPrint('[ARXIV][ERR] $e');
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
