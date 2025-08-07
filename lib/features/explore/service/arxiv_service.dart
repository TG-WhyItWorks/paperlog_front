import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/paper_model.dart';

class ArxivService {
  // 프록시 서버 엔드 포인트
  final _endpoint = 'https://your-proxy-server.com/api/arxiv';

  Future<List<Paper>> fetchPapers(String query) async {
    final url = Uri.parse(
      '$_endpoint?query=$query=${Uri.encodeQueryComponent(query)}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((json) => Paper.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load papers : ${response.statusCode}');
    }
  }
}
