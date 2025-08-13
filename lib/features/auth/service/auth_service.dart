import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/user_model.dart';
import '../../../core/services/token_storage.dart';
import 'package:flutter/foundation.dart';
import '../../../core/config/api_config.dart';

class AuthService {
  final _tokenStorage = TokenStorage();

  Map<String, String> _baseHeaders() => ApiConfig.baseHeaders();

  Future<UserModel> loginWithGoogle({
    String? accessToken,
    required String idToken,
  }) async {
    final uri = ApiConfig.uri('/auth/google');
    try {
      ApiConfig.logReq('AUTH POST', uri);
      final resp = await http
          .post(
            uri,
            headers: _baseHeaders(),
            body: json.encode({'accessToken': accessToken, 'idToken': idToken}),
          )
          .timeout(const Duration(seconds: 15));
      debugPrint('[AUTH] status=${resp.statusCode}, body=${resp.body}');

      if (resp.statusCode != 200) {
        throw Exception('Google login failed: ${resp.statusCode}');
      }
      final data = json.decode(resp.body) as Map<String, dynamic>;

      // 서버 응답 키가 다를 수 있어 안전하게 파싱
      final at =
          (data['accessToken'] ?? data['token'] ?? data['data']?['accessToken'])
              as String?;
      final rt =
          (data['refreshToken'] ?? data['data']?['refreshToken']) as String?;
      final userJson =
          (data['user'] ?? data['data']?['user']) as Map<String, dynamic>?;

      if (at == null || at.isEmpty) {
        throw Exception('No accessToken in response');
      }
      await _tokenStorage.save(accessToken: at, refreshToken: rt);
      debugPrint(
        '[AUTH] tokens saved. at.len=${at.length} rt.len=${rt?.length}',
      );

      if (userJson == null) {
        throw Exception('No user in response');
      }
      return UserModel.fromJson(userJson);
    } catch (e, st) {
      debugPrint('[AUTH][ERR] $e\n$st');
      rethrow;
    }
  }

  // 인증 필요한 API 호출 시 사용할 헤더
  Future<Map<String, String>> _authHeaders() async {
    final at = await _tokenStorage.readAccessToken();
    if (at == null || at.isEmpty) {
      return _baseHeaders();
    }
    return {..._baseHeaders(), 'Authorization': 'Bearer $at'};
  }

  // 프로필 가져오기 (401 나오면 refresh 고려)
  Future<UserModel> fetchProfile() async {
    final uri = ApiConfig.uri('/auth/me');
    final resp = await http.get(uri, headers: await _authHeaders());
    if (resp.statusCode == 401) {
      // 필요하면 여기서 refresh() 호출 후 1회 재시도하는 로직
      throw Exception('Unauthorized');
    }
    if (resp.statusCode != 200) {
      throw Exception(
        'Fetch profile failed: ${resp.statusCode} | ${resp.body}',
      );
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return UserModel.fromJson(data['user']);
  }

  // 토큰 갱신 (백엔드에 /auth/refresh가 있을 때)
  Future<void> refresh() async {
    final rt = await _tokenStorage.readRefreshToken();
    if (rt == null || rt.isEmpty) return;
    final uri = ApiConfig.uri('/auth/refresh');
    final resp = await http.post(
      uri,
      headers: _baseHeaders(),
      body: json.encode({'refreshToken': rt}),
    );
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body) as Map<String, dynamic>;
      final at = data['accessToken'] as String?;
      if (at != null && at.isNotEmpty) {
        await _tokenStorage.save(accessToken: at, refreshToken: rt);
      }
    }
  }

  Future<UserModel> loginWithEmail(String email, String password) async {
    final uri = ApiConfig.uri('/auth/email');
    final resp = await http.post(
      uri,
      headers: ApiConfig.baseHeaders(),
      body: json.encode({'email': email, 'password': password}),
    );

    if (resp.statusCode != 200) {
      throw Exception('Email login failed: ${resp.statusCode}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return UserModel.fromJson(data['user']);
  }

  Future<void> logout() async {
    try {
      final uri = ApiConfig.uri('/auth/logout');
      await http.post(uri, headers: ApiConfig.baseHeaders());
    } finally {
      await _tokenStorage.clear();
    }
  }
}
