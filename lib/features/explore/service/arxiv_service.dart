import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/paper_model.dart';
import 'package:flutter/foundation.dart';

class ArxivService {
  // 프록시 서버 엔드 포인트
  static const _host = 'daf1d4db1de5.ngrok-free.app';
  static const _path = '/api/arxiv';

  Map<String, String> _headers() => const {
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<List<Paper>> fetchPapers(String query) async {
    final uri = Uri.https(_host, _path, {'query': query});
    debugPrint('[ARXIV] GET $uri');

    final resp = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 15));
    debugPrint('[ARXIV] status=${resp.statusCode} len=${resp.body.length}');

    if (resp.statusCode != 200) {
      throw Exception('Failed to load papers: ${resp.statusCode}');
    }

    final decoded = json.decode(resp.body);

    // 응답이 배열: [ {...}, {...} ]
    if (decoded is List) {
      return decoded
          .map((e) => Paper.fromJson(_normalize(e as Map<String, dynamic>)))
          .toList();
    }

    // 응답이 객체: { results: [ {...} ] } 형태도 지원
    if (decoded is Map<String, dynamic> && decoded['results'] is List) {
      final list = decoded['results'] as List;
      return list
          .map((e) => Paper.fromJson(_normalize(e as Map<String, dynamic>)))
          .toList();
    }

    throw Exception('Unexpected response shape');
  }

  /// 백엔드가 snake_case를 쓰거나 키가 살짝 다른 경우를 흡수
  Map<String, dynamic> _normalize(Map<String, dynamic> j) {
    return {
      // 아래 키들은 Paper.fromJson에서 쓰는 키 이름에 맞춰 변환해주세요.
      'id': j['arxiv_id']?.toString() ?? '',
      'title': j['title'] ?? '',
      'summary': j['summary'] ?? j['abstract'] ?? '',
      'tags': (j['tags'] ?? j['categories'] ?? const [])
          .map((e) => e.toString())
          .toList(),
      'imageUrl': j['imageUrl'] ?? j['image_url'] ?? '',
      'recommendationReason': j['recommendationReason'] ?? j['reason'] ?? '',
      // 필요 시 publishDate 같은 필드도 추가
    };
  }
}
