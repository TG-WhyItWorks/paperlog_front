import 'package:flutter/material.dart';
import '../../../core/models/paper_detail_model.dart';
import '../service/paper_service.dart';

class PaperDetailViewModel extends ChangeNotifier {
  final PaperService _service = PaperService();

  bool isLoading = false;
  String? error;
  PaperDetail? detail;

  Future<void> loadDetail(String paperId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      detail = await _service.fetchDetail(paperId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
