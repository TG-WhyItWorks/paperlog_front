import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/token_storage.dart';
import '../../../core/config/api_config.dart';
import '../../../core/models/folder_model.dart';

class FolderService {
  final _tokenStorage = TokenStorage();

  Map<String, String> _baseHeaders() => {
    ...ApiConfig.baseHeaders(),
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _authHeaders() async {
    final at = await _tokenStorage.readAccessToken();
    if (at == null || at.isEmpty) return _baseHeaders();
    return {..._baseHeaders(), 'Authorization': 'Bearer $at'};
  }

  /// 폴더 목록 조회 (GET /folders)
  Future<List<LibraryFolder>> fetchFolders() async {
    final uri = ApiConfig.uri('/folders/root');
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 404) {
      // 백엔드가 루트 폴더 없으면 404 반환 → 프론트에선 빈 리스트로 처리
      return const <LibraryFolder>[];
    }

    if (res.statusCode != 200) {
      throw Exception('폴더 목록 조회 실패: HTTP ${res.statusCode} ${res.body}');
    }

    final List data = json.decode(res.body) as List;
    final out = <LibraryFolder>[];

    void walk(Map<String, dynamic> m) {
      final id = (m['id'] ?? '').toString();
      final name = (m['folder_name'] ?? m['name'] ?? '').toString();
      final parentId = (m['parent_folder_id'] != null)
          ? m['parent_folder_id'].toString()
          : null;
      final count = (m['folder_papers'] is List)
          ? (m['folder_papers'] as List).length
          : 0;

      out.add(
        LibraryFolder(id: id, name: name, count: count, parentId: parentId),
      );

      final subs = (m['subfolders'] as List? ?? const []);
      for (final s in subs) {
        walk(Map<String, dynamic>.from(s as Map));
      }
    }

    for (final item in data) {
      walk(Map<String, dynamic>.from(item as Map));
    }

    return out;
  }

  /// 폴더 생성 (FastAPI: POST /folders)
  Future<LibraryFolder> createFolder({
    required String folderName,
    int? parentFolderId,
  }) async {
    final uri = ApiConfig.uri('/folders/'); // 백엔드 라우트가 "/"에 매핑
    final res = await http
        .post(
          uri,
          headers: await _authHeaders(),
          body: json.encode({
            'folder_name': folderName,
            'parent_folder_id': parentFolderId, // null 허용
          }),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('폴더 생성 실패: HTTP ${res.statusCode} ${res.body}');
    }

    final map = json.decode(res.body) as Map<String, dynamic>;
    return LibraryFolder(
      id: (map['id'] ?? '').toString(),
      name: (map['folder_name'] ?? '').toString(),
      count: 0, // 새 폴더는 0에서 시작
      parentId: (map['parent_folder_id'] != null)
          ? (map['parent_folder_id']).toString()
          : null,
    );
  }

  /// 폴더 이름 변경 (PATCH /folders/{id})
  Future<void> renameFolder({
    required String folderId,
    required String newName,
    int? parentFolderId, // 변경 없으면 null 그대로 전달 가능
  }) async {
    final uri = ApiConfig.uri('/folders/${Uri.encodeComponent(folderId)}');
    final body = json.encode({
      'id': int.tryParse(folderId) ?? folderId,
      'folder_name': newName,
      'parent_folder_id': parentFolderId,
    });

    final res = await http
        .put(uri, headers: await _authHeaders(), body: body)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('폴더 이름 변경 실패: HTTP ${res.statusCode} ${res.body}');
    }
  }

  /// 폴더 삭제 (DELETE /folders/{id})
  Future<void> deleteFolder({required String folderId}) async {
    final uri = ApiConfig.uri('/folders/${Uri.encodeComponent(folderId)}');
    final res = await http
        .delete(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('폴더 삭제 실패: HTTP ${res.statusCode} ${res.body}');
    }
  }

  Future<void> addPaperToFolder({
    required int folderId,
    required int paperDbId,
    String? displayName,
  }) async {
    final uri = ApiConfig.uri('/folders/$folderId/items');
    final res = await http
        .post(
          uri,
          headers: await _authHeaders(),
          body: json.encode({
            'folder_paper_name': displayName ?? 'paper_$paperDbId',
            'folder_id': folderId,
            'paper_id': paperDbId,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('폴더 배치 실패: HTTP ${res.statusCode} ${res.body}');
    }
  }

  Future<void> addReviewToFolder({
    required int folderId,
    required int reviewId,
    String? displayName,
  }) async {
    final uri = ApiConfig.uri('/folders/$folderId/items');
    final res = await http
        .post(
          uri,
          headers: await _authHeaders(),
          body: json.encode({
            'folder_paper_name': displayName ?? 'review_$reviewId',
            'folder_id': folderId,
            'review_id': reviewId,
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('폴더 배치 실패: HTTP ${res.statusCode} ${res.body}');
    }
  }

  /// 폴더 안 항목 삭제 (DELETE /folders/{folderId}/items)
  Future<void> removeItemFromFolder({
    required int folderId,
    int? paperId,
    int? reviewId,
    String? paperArxivId,
  }) async {
    if (paperId == null &&
        reviewId == null &&
        (paperArxivId == null || paperArxivId.isEmpty)) {
      throw Exception('paperId, reviewId, paperArxivId 중 하나는 필요합니다.');
    }
    final uri = ApiConfig.uri('/folders/$folderId/items');
    final res = await http
        .delete(
          uri,
          headers: await _authHeaders(),
          body: json.encode({
            'folder_id': folderId,
            'paper_id': paperId,
            'review_id': reviewId,
            'paper_arxiv_id': paperArxivId,
          }),
        )
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('폴더 항목 삭제 실패: HTTP ${res.statusCode} ${res.body}');
    }
  }

  // ------------------------------
  // (구) 다건 추가 API 대체용(선택)
  // - 백엔드는 단건만 지원하므로 반복 호출
  // - paperIds는 DB 정수 ID여야 함
  // ------------------------------
  Future<void> addPapersToFolder({
    required String folderId,
    required List<int> paperIds, // DB 정수 id
  }) async {
    final fid = int.parse(folderId);
    for (final pid in paperIds) {
      final uri = ApiConfig.uri('/folders/$fid/items');
      final res = await http
          .post(
            uri,
            headers: await _authHeaders(),
            body: json.encode({
              'folder_paper_name': 'paper_$pid',
              'folder_id': fid,
              'paper_id': pid,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw Exception('폴더 배치 실패: HTTP ${res.statusCode} ${res.body}');
      }
    }
  }
}
