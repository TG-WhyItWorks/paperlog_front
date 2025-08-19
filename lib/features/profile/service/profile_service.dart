import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/models/profile_model.dart';

class ProfileService {
  String get _base => '${ApiConfig.baseUrl}';

  /// 프로필 업데이트 (부분 수정 가능)
  /// 서버 예시: PATCH /users/me { "username": "...", "bio": "...", "avatarUrl": "..." }
  Future<ProfileModel> updateProfile({
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    final uri = Uri.parse('$_base/users/me');
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (bio != null) body['bio'] = bio;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

    final resp = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception('프로필 업데이트 실패: ${resp.statusCode} ${resp.body}');
    }
    final jsonMap = json.decode(resp.body) as Map<String, dynamic>;
    return ProfileModel(
      avatarUrl: (jsonMap['avatarUrl'] ?? '') as String,
      username: (jsonMap['username'] ?? '') as String,
      bio: (jsonMap['bio'] ?? '') as String,
      subtitle: (jsonMap['email'] ?? '') as String, // 서버 필드명에 맞게 조정
      followers: (jsonMap['followers'] ?? 0) as int,
      following: (jsonMap['following'] ?? 0) as int,
    );
  }

  /// 아바타 업로드
  /// 서버 예시: POST /users/me/avatar  (multipart/form-data)
  /// 반환: 업로드된 이미지의 공개 URL
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String filename,
  }) async {
    final uri = Uri.parse('$_base/users/me/avatar');
    final req = http.MultipartRequest('POST', uri);

    req.files.add(
      http.MultipartFile.fromBytes(
        'file', // 서버 필드명에 맞게
        bytes,
        filename: filename,
        contentType: null, // 서버에서 감지 가능. 필요 시 MediaType.parse("image/jpeg")
      ),
    );

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('아바타 업로드 실패: ${resp.statusCode} ${resp.body}');
    }
    final jsonMap = json.decode(resp.body) as Map<String, dynamic>;
    // 서버가 { "avatarUrl": "..." } 형태로 반환한다고 가정
    return (jsonMap['avatarUrl'] ?? '') as String;
  }
}
