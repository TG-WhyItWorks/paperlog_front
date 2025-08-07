import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/user_model.dart';

class AuthService {
  final String baseUrl = 'https://your-server.com/api/auth';

  Future<UserModel> loginWithGoogle({
    required String accessToken,
    required String idToken,
  }) async {
    final uri = Uri.parse('$baseUrl/google');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'accessToken': accessToken, 'idToken': idToken}),
    );

    if (resp.statusCode != 200) {
      throw Exception('Google login failed: ${resp.statusCode}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> loginWithEmail(String email, String password) async {
    final uri = Uri.parse('$baseUrl/email');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (resp.statusCode != 200) {
      throw Exception('Email login failed: ${resp.statusCode}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return UserModel.fromJson(data['user']);
  }

  Future<void> logout() async {
    final uri = Uri.parse('$baseUrl/logout');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
  }
}
