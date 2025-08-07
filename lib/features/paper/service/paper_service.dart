import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/paper_detail_model.dart';

class PaperService {
  final String baseUrl = 'https://your-server.com/api';

  Future<PaperDetail> fetchDetail(String paperId) async {
    final uri = Uri.parse('$baseUrl/papers/$paperId');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('논문 상세 조회 실패: HTTP ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return PaperDetail.fromJson(data);
  }
}
