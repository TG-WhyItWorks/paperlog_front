import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<void> save({required String accessToken, String? refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccess, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_kRefresh, refreshToken);
    }
  }

  Future<String?> readAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccess);
  }

  Future<String?> readRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRefresh);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccess);
    await prefs.remove(_kRefresh);
  }
}
