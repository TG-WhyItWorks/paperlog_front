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
    hasSearched = true;
    notifyListeners();
    if (query.trim().isEmpty) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      papers = await _service.fetchPapers(query);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
