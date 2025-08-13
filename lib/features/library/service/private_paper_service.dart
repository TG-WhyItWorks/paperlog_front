import 'package:paperlog_front/core/models/paper_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../../../core/services/token_storage.dart';
import '../../../core/config/api_config.dart';

class PrivatePaperService {
  final _tokenStorage = TokenStorage();

  /// Private PDF 업로드 (FastAPI: POST /private-papers/upload)
  Future<Paper> uploadPrivatePdf({
    required String filename,
    required Uint8List bytes,
    Map<String, String>? fields,
    int? folderId,
  }) async {
    final uri = ApiConfig.uri('/private-papers/upload');
    final req = http.MultipartRequest('POST', uri);
    if (fields != null) req.fields.addAll(fields);
    // 인증/ngrok 헤더 추가
    final at = await _tokenStorage.readAccessToken();
    req.headers['Accept'] = 'application/json';
    if (at != null && at.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $at';
    }
    if (folderId != null) {
      // 백엔드가 기대하는 키에 맞춰 전달 (예: folder_id)
      req.fields['folder_id'] = folderId.toString();
    }

    req.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    final streamed = await req.send().timeout(const Duration(seconds: 30));
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('업로드 실패: HTTP ${res.statusCode}');
    }
    final decoded = json.decode(res.body);
    final map = (decoded is Map && decoded['paper'] is Map)
        ? Map<String, dynamic>.from(decoded['paper'] as Map)
        : Map<String, dynamic>.from(decoded as Map);
    return Paper.fromJson(map);
  }
}
