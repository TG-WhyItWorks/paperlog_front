import 'package:flutter/material.dart';
import '../../../core/models/library_models.dart';
import '../service/library_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../../core/models/paper_model.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class LibraryViewModel extends ChangeNotifier {
  final _service = LibraryService();

  bool isLoading = false;
  String? error;
  String query = '';
  List<LibraryItem> items = [];

  // 로그인 사용자별 폴더 캐시(메모리)
  final Map<int, List<LibraryFolder>> _userFolders = {};
  // 현재 화면에 바인딩된 폴더(로그인 사용자 기준)
  List<LibraryFolder> _folders = const <LibraryFolder>[];
  List<LibraryFolder> get folders => _folders;

  //선택 상테
  final Set<String> selectedPaperIds = {};
  final Set<String> selectedPostIds = {};

  // ------------------------------
  // 선택 상태/헬퍼
  // ------------------------------
  bool get isSelecting =>
      selectedPaperIds.isNotEmpty || selectedPostIds.isNotEmpty;

  int get selectedPaperCount => selectedPaperIds.length;
  int get selectedPostCount => selectedPostIds.length;

  bool isPaperSelected(String id) => selectedPaperIds.contains(id);

  void togglePaperSelected(String id) {
    if (!selectedPaperIds.remove(id)) selectedPaperIds.add(id);
    notifyListeners();
  }

  void clearSelection() {
    selectedPaperIds.clear();
    selectedPostIds.clear();
    notifyListeners();
  }

  // ------------------------------
  // 액션: 섹션으로 이동(워치리스트/리딩/완료)
  // ------------------------------
  Future<void> moveSelectedToSection(LibrarySection section) async {
    final ids = selectedPaperIds.toSet();
    if (ids.isEmpty) return;

    isLoading = true;
    notifyListeners();
    try {
      // 서버가 있으면 호출
      // await _service.movePapersToSection(ids.toList(), section);

      // 메모리 갱신
      items = items
          .map(
            (e) => ids.contains(e.paper.id)
                ? LibraryItem(
                    paper: e.paper,
                    section: section,
                    isPrivate: e.isPrivate,
                  )
                : e,
          )
          .toList(growable: false);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      clearSelection();
      notifyListeners();
    }
  }

  // ------------------------------
  // 액션: 폴더로 이동
  // ------------------------------
  Future<void> moveSelectedToFolder(String folderId) async {
    final ids = selectedPaperIds.toList();
    if (ids.isEmpty) return;

    isLoading = true;
    notifyListeners();
    try {
      // 서버가 있으면 호출 (folderId는 숫자면 parse)
      // final fid = int.tryParse(folderId);
      // await _service.movePapersToFolder(ids, folderId: fid);

      // 폴더 카운트 +n 반영(간단 버전)
      final uid = _auth?.userId;
      if (uid != null) {
        final list = [...(_userFolders[uid] ?? const <LibraryFolder>[])];
        final idx = list.indexWhere((f) => f.id == folderId);
        if (idx != -1) {
          final f = list[idx];
          list[idx] = LibraryFolder(
            id: f.id,
            name: f.name,
            count: f.count + ids.length,
            parentId: f.parentId,
          );
          _userFolders[uid] = list;
          _folders = list;
        }
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      clearSelection();
      notifyListeners();
    }
  }

  // ------------------------------
  // 액션: 선택 삭제
  // ------------------------------
  Future<void> deleteSelected() async {
    final ids = selectedPaperIds.toList();
    if (ids.isEmpty) return;

    isLoading = true;
    notifyListeners();
    try {
      // 서버가 있으면 호출
      // await _service.deletePapers(ids);

      // 메모리 삭제
      items = items
          .where((e) => !ids.contains(e.paper.id))
          .toList(growable: false);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      clearSelection();
      notifyListeners();
    }
  }

  // ------------------------------
  // 폴더 편집(호버 시 아이콘용)
  // ------------------------------
  Future<void> renameFolder(String folderId, String newName) async {
    final uid = _auth?.userId;
    if (uid == null || newName.trim().isEmpty) return;

    try {
      // await _service.renameFolder(folderId: int.tryParse(folderId), name: newName);
      final list = [...(_userFolders[uid] ?? const <LibraryFolder>[])];
      final idx = list.indexWhere((f) => f.id == folderId);
      if (idx != -1) {
        final f = list[idx];
        list[idx] = LibraryFolder(
          id: f.id,
          name: newName,
          count: f.count,
          parentId: f.parentId,
        );
        _userFolders[uid] = list;
        _folders = list;
      }
    } catch (e) {
      error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteFolder(String folderId) async {
    final uid = _auth?.userId;
    if (uid == null) return;

    try {
      // await _service.deleteFolder(folderId: int.tryParse(folderId));
      final list = [...(_userFolders[uid] ?? const <LibraryFolder>[])];
      list.removeWhere((f) => f.id == folderId);
      _userFolders[uid] = list;
      _folders = list;
    } catch (e) {
      error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // ------------------------------
  // 간단 새로고침 훅 (필요할 때 UI에서 호출)
  // ------------------------------
  Future<void> refresh() async {
    await load();
  }

  AuthViewModel? _auth;
  void bindAuth(AuthViewModel auth) {
    if (_auth == auth) return;
    _auth?.removeListener(_onAuthChanged);
    _auth = auth;
    _auth!.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  Future<void> init() async {
    await load();
  }

  void _onAuthChanged() {
    final uid = _auth?.userId;
    if (uid == null) {
      // 로그아웃: 커스텀 폴더 숨김, 프라이빗 항목 숨김
      _folders = const <LibraryFolder>[];
      items = items.where((e) => !e.isPrivate).toList(growable: false);
      notifyListeners();
      return;
    }
    // 로그인: 사용자별 폴더 반영
    _folders = _userFolders[uid] ?? const <LibraryFolder>[];
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
    // 비로그인 시 private 섹션은 숨김
    final list = filtered.where((e) => e.section == s).toList(growable: false);
    if (s == LibrarySection.private && (_auth?.isLoggedIn != true)) {
      return const <LibraryItem>[];
    }
    return list;
  }

  /// 폴더 생성 (API 호출)
  Future<void> createFolder(String name, {int? parentFolderId}) async {
    final n = name.trim();
    if (n.isEmpty) return;
    if (_auth?.userId == null) return; // 비로그인 방지
    final uid = _auth!.userId!;
    try {
      isLoading = true;
      notifyListeners();
      final created = await _service.createFolder(
        folderName: n,
        parentFolderId: parentFolderId,
      );
      final List<LibraryFolder> list = [
        ...(_userFolders[uid] ?? const <LibraryFolder>[]),
        created,
      ];
      _userFolders[uid] = list;
      _folders = list;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 선택한 폴더에 업로드
  Future<void> uploadPrivatePaperToFolder(
    BuildContext context, {
    required String folderIdStr,
  }) async {
    if (_auth?.isLoggedIn != true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 후 이용해 주세요.')));
      return;
    }
    final folderId = int.tryParse(folderIdStr);
    if (folderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('잘못된 폴더 ID 입니다.')));
      return;
    }
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) throw Exception('파일 바이트를 읽지 못했습니다.');

      isLoading = true;
      error = null;
      notifyListeners();

      final paper = await _service.uploadPrivatePdf(
        filename: file.name,
        bytes: bytes,
        fields: const {'visibility': 'private'},
        folderId: folderId, // 폴더 지정 업로드
      );

      // 라이브러리 리스트에 반영 (private 섹션으로 표기)
      items = [
        LibraryItem(
          paper: paper,
          section: LibrarySection.private,
          isPrivate: true,
        ),
        ...items,
      ];

      // 폴더 count +1 반영
      final uid = _auth!.userId!;
      final list = [...(_userFolders[uid] ?? const <LibraryFolder>[])];
      final idx = list.indexWhere((f) => f.id == folderIdStr);
      if (idx != -1) {
        final f = list[idx];
        list[idx] = LibraryFolder(
          id: f.id,
          name: f.name,
          count: f.count + 1,
          parentId: f.parentId,
        );
        _userFolders[uid] = list;
        _folders = list;
      }

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

  /// 파일 선택 → 업로드 → 리스트 반영
  Future<void> uploadPrivatePaper(BuildContext context) async {
    if (_auth?.isLoggedIn != true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인 후 이용해 주세요.')));
      return;
    }
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
