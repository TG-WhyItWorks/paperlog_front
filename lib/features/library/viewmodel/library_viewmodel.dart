import 'package:flutter/material.dart';
import '../../../core/models/library_models.dart';
import '../service/library_service.dart';

class LibraryViewModel extends ChangeNotifier {
  final _service = LibraryService();

  bool isLoading = false;
  String? error;
  String query = '';
  List<LibraryItem> items = [];

  // 사용자 폴더
  List<LibraryFolder> folders = const [];

  Future<void> init() async {
    await load();
    // 샘플 폴더 (서버 연동 시 API 결과로 교체)
    folders = const [
      LibraryFolder(id: 'ml', name: 'Machine Learning', count: 5),
      LibraryFolder(id: 'flutter', name: 'Flutter Development', count: 3),
      LibraryFolder(id: 'ds', name: 'Data Science', count: 8),
    ];
    notifyListeners();
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
        : items.where((e) {
            final p = e.paper;
            final inTitle = p.title.toLowerCase().contains(q);
            final inAbs = p.abstractText.toLowerCase().contains(q);
            final inAuthors = p.authors.any((a) => a.toLowerCase().contains(q));
            final inFields = p.fields.any((f) => f.toLowerCase().contains(q));
            return inTitle || inAbs || inAuthors || inFields;
          });
    return filtered.where((e) => e.section == s).toList(growable: false);
  }

  /// 폴더 생성
  void createFolder(String name) {
    final n = name.trim();
    if (n.isEmpty) return;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    folders = [...folders, LibraryFolder(id: id, name: n, count: 0)];
    notifyListeners();
  }
}
