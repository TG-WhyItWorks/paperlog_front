import 'package:flutter/material.dart';
import '../../../core/models/library_models.dart';
import '../service/library_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../../core/models/paper_model.dart';

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

  /// 파일 선택 → 업로드 → 리스트 반영
  Future<void> uploadPrivatePaper(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final Uint8List? bytes = file.bytes;
      if (bytes == null) throw Exception('파일 바이트를 읽지 못했습니다.');

      isLoading = true;
      error = null;
      notifyListeners();

      final paper = await _service.uploadPrivatePdf(
        filename: file.name,
        bytes: bytes,
        fields: {'visibility': 'private'},
      );

      items = [
        LibraryItem(
          paper: paper,
          section: LibrarySection.private,
          isPrivate: true,
        ),
        ...items,
      ];

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('업로드 완료')));
    } catch (e) {
      error = e.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('업로드 실패: $error')));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
