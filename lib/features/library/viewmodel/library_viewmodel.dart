import 'package:flutter/material.dart';
import '../../../core/models/library_models.dart';
import '../service/library_service.dart';

class LibraryViewmodel extends ChangeNotifier {
  final _service = LibraryService();

  bool isLoading = false;
  String? error;
  String query = '';
  List<LibraryItem> items = [];

  Future<void> init() async {
    await load();
  }

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      items = await _service.fetchLibrary();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateQuery(String value) {
    query = value;
    notifyListeners();
  }

  List<LibraryItem> section(LibrarySection s) {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items.where(
            (e) =>
                e.paper.title.toLowerCase().contains(q) ||
                e.paper.summary.toLowerCase().contains(q) ||
                e.paper.tags.any((t) => t.toLowerCase().contains(q)),
          );
    return filtered.where((e) => e.section == s).toList(growable: false);
  }
}
