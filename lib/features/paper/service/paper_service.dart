import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/paper_detail_model.dart';
import 'package:flutter/foundation.dart';

class PaperService {
  static const _host = 'f79dcee01290.ngrok-free.app';
  static const _basePath = '/api';

  Map<String, String> _headers() => const {
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  Future<PaperDetail> fetchDetail(String paperId) async {
    final uri = Uri.https(_host, '$_basePath/papers/$paperId');
    debugPrint('[DETAIL] GET $uri');

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
