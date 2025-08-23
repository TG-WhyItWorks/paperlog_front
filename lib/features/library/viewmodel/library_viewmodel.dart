import 'package:flutter/material.dart';
import '../../../core/models/library_models.dart';
import '../service/library_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../../../core/models/paper_model.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../../core/models/folder_model.dart';
import '../service/folder_service.dart';
import '../service/private_paper_service.dart';

class LibraryViewModel extends ChangeNotifier {
  final _service = LibraryService();
  final _folderService = FolderService();
  final _privatePaperService = PrivatePaperService();

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

  final Map<String, Set<String>> _paperFolderMap = {};
  bool isInSection(String paperId, LibrarySection s) {
    return items.any((e) => e.paper.id == paperId && e.section == s);
  }

  bool isInFolder(String paperId, String folderId) {
    final set = _paperFolderMap[paperId];
    return set?.contains(folderId) ?? false;
  }

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
  // 액션: 섹션으로 이동(워치리스트/리딩/완료) - 서버 연동
  // ------------------------------
  Future<void> moveSelectedToSection(LibrarySection section) async {
    final ids = selectedPaperIds.toList();
    if (ids.isEmpty) return;

    isLoading = true;
    notifyListeners();
    try {
      // 1) 서버 호출
      await _service.movePapersToSection(ids: ids, section: section);

      // 2) 로컬 상태 갱신
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
  // 액션: 폴더로 이동 - 서버 연동
  // ------------------------------
  Future<void> moveSelectedToFolder(String folderId) async {
    final ids = selectedPaperIds.toList();
    if (ids.isEmpty) return;

    // 문자열 → 정수(DB id) 변환. 변환 실패한 것은 전송 제외
    final dbIds = ids.map((s) => int.tryParse(s)).whereType<int>().toList();
    final skipped = ids.length - dbIds.length;
    if (dbIds.isEmpty) {
      error = '선택한 항목에 서버 DB id가 없어 폴더에 추가할 수 없습니다.';
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();
    try {
      // 1) 서버 호출 (List<int>)
      await _folderService.addPapersToFolder(
        folderId: folderId,
        paperIds: dbIds,
      );

      // 2) 로컬 매핑/카운트 반영 (원래 문자열 id 기준으로 유지)
      var newlyAdded = 0;
      for (final pid in ids) {
        final set = _paperFolderMap.putIfAbsent(pid, () => <String>{});
        if (set.add(folderId)) newlyAdded += 1;
      }
      if (newlyAdded > 0) _bumpFolderCount(folderId, newlyAdded);

      // 3) 서버 기준으로 동기화
      await refreshFolders();

      // (선택) 변환 실패 안내
      if (skipped > 0) {
        // 스낵바/로그 등으로 알려도 좋습니다
        debugPrint('폴더 추가에서 $skipped개는 DB id가 없어 제외됨');
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
      // 1) 서버 삭제
      await _service.deletePapers(ids: ids);

      // 2) (기존) 폴더 카운트/로컬 리스트 갱신
      final Map<String, int> dec = {}; //folderId -> 감소 개수
      for (final pid in ids) {
        final folders = _paperFolderMap.remove(pid);
        if (folders != null) {
          for (final fid in folders) {
            dec[fid] = (dec[fid] ?? 0) + 1;
          }
        }
      }
      dec.forEach((fid, n) => _bumpFolderCount(fid, -n));

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
      await _folderService.renameFolder(folderId: folderId, newName: newName);
      await refreshFolders();
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
      await _folderService.deleteFolder(folderId: folderId);
      // 매핑에서 해당 폴더 제거
      _paperFolderMap.updateAll((_, set) {
        set.remove(folderId);
        return set;
      });
      _paperFolderMap.removeWhere((_, set) => set.isEmpty);
      await refreshFolders();
    } catch (e) {
      error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  /// 폴더 안의 특정 paper를 제거
  Future<void> removePaperFromFolder({
    required String folderIdStr,
    required String paperIdStr,
  }) async {
    final fid = int.tryParse(folderIdStr);
    if (fid == null) {
      error = '잘못된 ID 형식입니다.(folderId)';
      notifyListeners();
      return;
    }
    final pid = int.tryParse(paperIdStr);
    isLoading = true;
    notifyListeners();
    try {
      await _folderService.removeItemFromFolder(
        folderId: fid,
        paperId: pid, // 정수일 때만 사용
        paperArxivId: pid == null ? paperIdStr : null, // 정수 변환 실패 → arXiv로 삭제
      );
      // 로컬 매핑 및 카운트 반영
      final set = _paperFolderMap[paperIdStr];
      if (set != null && set.remove(folderIdStr)) {
        if (set.isEmpty) _paperFolderMap.remove(paperIdStr);
        _bumpFolderCount(folderIdStr, -1);
      }
      await refreshFolders();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
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

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChanged);
    super.dispose();
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
    // 로그인: 캐시 없으면 서버에서 로드, 있으면 캐시 반영
    if (_userFolders.containsKey(uid)) {
      _folders = _userFolders[uid]!;
      notifyListeners();
    } else {
      // await 불필요: 비동기로 가져오고 UI는 캐시 도착 시 갱신
      refreshFolders();
    }
  }

  /// 서버에서 폴더 목록을 새로 로드하고 바인딩
  Future<void> refreshFolders() async {
    final uid = _auth?.userId;
    if (uid == null) return;
    try {
      final list = await _folderService.fetchFolders();
      if (list.isEmpty) {
        // 최초 사용자: 기본 루트 폴더를 하나 생성
        await _folderService.createFolder(folderName: 'My Collections');
        // 다시 조회
        final list2 = await _folderService.fetchFolders();
        _userFolders[uid] = list2;
        _folders = list2;
      } else {
        _userFolders[uid] = list;
        _folders = list;
      }
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
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

    try {
      isLoading = true;
      notifyListeners();
      final created = await _folderService.createFolder(
        folderName: n,
        parentFolderId: parentFolderId,
      );
      await refreshFolders();
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

      final paper = await _privatePaperService.uploadPrivatePdf(
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
        list[idx] = f.copyWith(count: f.count + 1);
        _userFolders[uid] = list;
        _folders = list;
      }

      // 폴더-논문 매핑 반영 → 폴더 트리에서 바로 표시되도록
      final set = _paperFolderMap.putIfAbsent(paper.id, () => <String>{});
      set.add(folderIdStr);
      notifyListeners();

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

      final paper = await _privatePaperService.uploadPrivatePdf(
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

  /// 빠른 리스트(워치/리딩/완료) 지정/해제
  Future<void> setInSection(Paper paper, LibrarySection s, bool on) async {
    final quick = {
      LibrarySection.wantToRead,
      LibrarySection.reading,
      LibrarySection.completed,
    };

    // 서버 반영 먼저 시도
    try {
      if (on) {
        await _service.movePapersToSection(ids: [paper.id], section: s);
      } else {
        // 해제는 'none'으로 보내는 방식(백엔드 계약에 따라 조정)
        await _service.movePapersToSection(
          ids: [paper.id],
          section: LibrarySection.none,
        );
      }
    } catch (e) {
      error = e.toString();
      // 실패 시 여기서 return 하면 로컬 상태는 그대로, 필요 시 스낵바 표시
      notifyListeners();
      return;
    }

    // === 아래는 기존 로컬 반영 로직 유지 ===
    if (on) {
      items = items
          .where((e) {
            if (e.paper.id != paper.id) return true;
            return !quick.contains(e.section);
          })
          .toList(growable: true);

      final exists = items.any((e) => e.paper.id == paper.id && e.section == s);
      if (!exists) {
        items.insert(
          0,
          LibraryItem(paper: paper, section: s, isPrivate: false),
        );
      }
    } else {
      items = items
          .where((e) => e.paper.id != paper.id || e.section != s)
          .toList(growable: true);
    }

    notifyListeners();
  }

  void _bumpFolderCount(String folderId, int delta) {
    final uid = _auth?.userId;
    if (uid == null) return;
    final list = [...(_userFolders[uid] ?? const <LibraryFolder>[])];
    final i = list.indexWhere((f) => f.id == folderId);
    if (i != -1) {
      final f = list[i];
      list[i] = f.copyWith(count: (f.count + delta).clamp(0, 1 << 30));
      _userFolders[uid] = list;
      _folders = list;
    }
  }

  // 선택 다이얼로그에서 트리 대신 납작 리스트로 보여줄 때 들여쓰기 계산용
  List<({LibraryFolder f, int depth})> flattenedFolders() {
    final List<({LibraryFolder f, int depth})> out = [];
    final byParent = <String?, List<LibraryFolder>>{};
    for (final f in folders) {
      byParent.putIfAbsent(f.parentId, () => []).add(f);
    }
    void walk(String? pid, int d) {
      for (final f in (byParent[pid] ?? const [])) {
        out.add((f: f, depth: d));
        walk(f.id, d + 1);
      }
    }

    walk(null, 0);
    return out;
  }

  // 해당 폴더에 속한 논문 반환
  List<LibraryItem> itemsInFolder(String folderId) {
    final ids = _paperFolderMap.entries
        .where((e) => e.value.contains(folderId))
        .map((e) => e.key)
        .toSet();
    return items.where((e) => ids.contains(e.paper.id)).toList(growable: false);
  }

  // items에 논문이 없으면 하나 추가
  void _ensureItemInList(Paper paper) {
    if (!items.any((e) => e.paper.id == paper.id)) {
      items = [
        LibraryItem(
          paper: paper,
          section: LibrarySection.none,
          isPrivate: false,
        ),
        ...items,
      ];
    }
  }

  //폴더 포함/제외
  Future<void> setInFolder({
    required Paper paper,
    required String folderId,
    required bool on,
  }) async {
    _ensureItemInList(paper);
    final paperId = paper.id;

    final set = _paperFolderMap.putIfAbsent(paperId, () => <String>{});
    final before = set.length;

    if (on) {
      if (set.add(folderId)) _bumpFolderCount(folderId, 1);
    } else {
      if (set.remove(folderId)) _bumpFolderCount(folderId, -1);
      if (set.isEmpty) _paperFolderMap.remove(paperId);
    }

    if (set.length != before) {
      // TODO: 서버 동기화 필요시 여기서 API 호출
      notifyListeners();
    }
  }
}
