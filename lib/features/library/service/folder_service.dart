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
    final uri = ApiConfig.uri('/folders');
    final res = await http
        .get(uri, headers: await _authHeaders())
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('폴더 목록 조회 실패: HTTP ${res.statusCode} ${res.body}');
    }
    final data = json.decode(res.body);
    final list = (data is List) ? data : (data['items'] as List? ?? const []);
    return list.map<LibraryFolder>((e) {
      final m = (e as Map).cast<String, dynamic>();
      return LibraryFolder(
        id: (m['id'] ?? '').toString(),
        name: (m['folder_name'] ?? m['name'] ?? '').toString(),
        count: (m['count'] is int) ? m['count'] as int : 0,
        parentId: (m['parent_folder_id'] != null)
            ? (m['parent_folder_id']).toString()
            : null,
      );
    }).toList();
  }

  /// 폴더 생성 (FastAPI: POST /folders)
  Future<LibraryFolder> createFolder({
    required String folderName,
    int? parentFolderId,
  }) async {
    final uri = ApiConfig.uri('/folders');
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
      count: (map['count'] is int) ? map['count'] as int : 0,
      parentId: (map['parent_folder_id'] != null)
          ? (map['parent_folder_id']).toString()
          : null,
    );
  }

  /// 폴더 이름 변경 (PATCH /folders/{id})
  Future<void> renameFolder({
    required String folderId,
    required String newName,
  }) async {
    final uri = ApiConfig.uri('/folders/${Uri.encodeComponent(folderId)}');
    final res = await http
        .patch(
          uri,
          headers: await _authHeaders(),
          body: json.encode({'folder_name': newName}),
        )
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

  /// (선택) 선택 논문을 폴더에 배치 (POST /folders/{id}/papers)
  /// 백엔드 라우트가 다르면 여기만 맞춰주세요.
  Future<void> addPapersToFolder({
    required String folderId,
    required List<String> paperIds,
  }) async {
    final uri = ApiConfig.uri(
      '/folders/${Uri.encodeComponent(folderId)}/papers',
    );
    final res = await http
        .post(
          uri,
          headers: await _authHeaders(),
          body: json.encode({'paper_ids': paperIds}),
        )
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('폴더 배치 실패: HTTP ${res.statusCode} ${res.body}');
    }
  }
}
