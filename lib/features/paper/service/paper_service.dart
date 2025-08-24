import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/paper_detail_model.dart';
import 'package:flutter/foundation.dart';
import '../../../core/config/api_config.dart';

class PaperService {
  Map<String, String> _headers() => {
    ...ApiConfig.baseHeaders(json: false),
    'Accept': 'application/json',
  };

  Future<PaperDetail> fetchDetail(String paperId) async {
    final uri = ApiConfig.uri('/api/arxiv/$paperId');
    ApiConfig.logReq('[DETAIL] GET', uri);

    final response = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 15));

    debugPrint(
      '[DETAIL] status = ${response.statusCode}, body=${response.body}',
    );
    if (response.statusCode != 200) {
      throw Exception('논문 상세 조회 실패: HTTP ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return PaperDetail.fromJson(data);
  }
}
