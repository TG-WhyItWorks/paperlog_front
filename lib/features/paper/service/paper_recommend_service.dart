import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/models/paper_model.dart';
import 'package:flutter/foundation.dart';

class PaperRecommendService {
  Map<String, String> _headers() => ApiConfig.baseHeaders();

  /// 서버: GET /api/search/papers/top/{category}
  /// 예) category: 'trending', 'popular', 'cs.CL', 'cs.LG' 등
  Future<List<Paper>> topByCategory(
    String category, {
    int? limit, // 서버가 limit를 받지 않아도, 클라이언트에서 sublist로 제한
  }) async {
    final path = '/api/search/papers/top/$category';
    final uri = ApiConfig.uri(path);
    ApiConfig.logReq('[TOP_PAPERS] GET', uri);

    final resp = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 15));

    debugPrint('[TOP_PAPERS] status=${resp.statusCode}, body=${resp.body}');
    if (resp.statusCode != 200) {
      throw Exception('추천 논문 조회 실패: HTTP ${resp.statusCode}');
    }

    final raw = json.decode(resp.body);
    if (raw is! List) return const [];

    var list = raw
        .whereType<Map>()
        .map((e) => Paper.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    if (limit != null && limit > 0 && list.length > limit) {
      list = list.sublist(0, limit);
    }
    return list;
  }
}
