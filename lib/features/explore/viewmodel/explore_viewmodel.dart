import 'package:flutter/material.dart';
import '../../../core/models/paper_model.dart';
import '../service/arxiv_service.dart';

class ExploreViewModel extends ChangeNotifier {
  final _service = ArxivService();

  bool isLoading = false;
  String? errorMessage;
  List<Paper> papers = [];
  bool hasSearched = false;
  String _lastQuery = '';

  Future<void> search(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      // 초기 상태 유지
      return;
    }

    if (q == _lastQuery && papers.isNotEmpty) {
      //동일 쿼리로의 재검색 방지
      return;
    }

    hasSearched = true;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      papers = await _service.fetchPapers(q);
      debugPrint('[ARXIV] parsed papers = ${papers.length}');
      _lastQuery = q;
    } catch (e) {
      debugPrint('[ARXIV][ERR] $e');
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
