import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../../core/models/paper_model.dart';

class PaperSearchService {
  Future<List<Paper>> search(
    String keyword, {
    int skip = 0,
    int limit = 30,
  }) async {
    final uri = ApiConfig.uri('/api/arxiv/', {
      'query': keyword,
      'skip': '$skip',
      'limit': '$limit',
    });
    final res = await http
        .get(uri, headers: ApiConfig.baseHeaders())
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('논문 검색 실패: HTTP ${res.statusCode} ${res.body}');
    }

    final list = json.decode(res.body) as List;
    return list
        .whereType<Map>()
        .map((e) => Paper.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
