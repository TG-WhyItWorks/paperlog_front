import 'package:flutter/foundation.dart';

/// 서버와 연결할 때는 뒷 주소만 바꿔서 실행
/// flutter run -d chrome --web-port 5173 --dart-define=API_URL=https://daf1d4db1de5.ngrok-free.app
class ApiConfig {
  static const String _envBase = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );

  static final String baseUrl = _envBase.isNotEmpty
      ? _envBase
      : 'http://localhost:8000';

  // 공통 헤더 (ngrok 경고 우회 포함)
  static Map<String, String> baseHeaders({bool json = true}) {
    return {
      if (json) 'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
  }

  // (path, query)로 최종 요청 URI 생성
  static Uri uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(baseUrl);
    final mergedPath = _join(base.path, path);
    return base.replace(
      path: mergedPath,
      queryParameters: query?.map((k, v) => MapEntry(k, v?.toString())),
    );
  }

  // path 합치기 (base.path + path)
  static String _join(String a, String b) {
    final left = a.endsWith('/') ? a.substring(0, a.length - 1) : a;
    final right = b.startsWith('/') ? b : '/$b';
    return '$left$right';
  }

  // 개발 디버그 로그
  static void logReq(String tag, Uri uri) {
    debugPrint('[$tag] $uri');
  }
}
