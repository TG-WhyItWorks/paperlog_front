import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/paper_model.dart';
import 'package:flutter/foundation.dart';
import '../../../core/config/api_config.dart';

class ArxivService {
  // 프록시 서버 엔드 포인트
  static const _host = 'daf1d4db1de5.ngrok-free.app';
  static const _path = '/api/arxiv';

  Map<String, String> _headers() => {
    ...ApiConfig.baseHeaders(json: false),
    'Accept': 'application/json',
  };

  Future<List<Paper>> fetchPapers(String query) async {
    final uri = ApiConfig.uri('api/arxiv', {'query': query});
    ApiConfig.logReq('[ARXIV] GET', uri);

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

  Map<String, dynamic> _normalize(Map<String, dynamic> j) {
    List<String> _asList(dynamic v) {
      if (v == null) return const <String>[];
      if (v is List) return v.map((e) => e.toString()).toList();
      if (v is String) {
        return v
            .split(RegExp(r',|\|')) // "A, B" 또는 "A|B"
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return const <String>[];
    }

    // 저자가 객체 리스트로 오는 경우 [{name: '...'}] 대응
    List<String> _authors(dynamic v) {
      if (v is List && v.isNotEmpty && v.first is Map) {
        return v
            .map((e) => (e as Map)['name']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return _asList(v);
    }

    String _pdfUrl(Map<String, dynamic> j) {
      final s = j['pdf_url'] ?? j['pdfUrl'] ?? j['link'] ?? j['url'];
      if (s is String && s.isNotEmpty) return s;
      // arXiv 스타일: links: [{rel:'alternate'| 'pdf', href:...}]
      if (j['links'] is List) {
        final links = (j['links'] as List).cast<dynamic>();
        final pdf = links.cast<Map>().firstWhere(
          (m) => (m['rel']?.toString() ?? '').toLowerCase() == 'pdf',
          orElse: () => const {},
        );
        if (pdf['href'] is String) return pdf['href'] as String;
        final first = links.cast<Map>().firstWhere(
          (m) => m['href'] is String,
          orElse: () => const {},
        );
        if (first['href'] is String) return first['href'] as String;
      }
      return '';
    }

    // published는 문자열 또는 epoch(int)로 들어올 수 있음 → 그대로 Paper.fromJson에 전달
    final published =
        j['published'] ??
        j['publishDate'] ??
        j['published_at'] ??
        j['updated'] ??
        j['date'];

    return {
      // Paper.fromJson이 이해하는 키들로 맞춰서 리매핑
      'id': j['arxiv_id']?.toString() ?? j['id']?.toString() ?? '',
      'title': j['title'] ?? '',
      'summary': j['summary'] ?? j['abstract'] ?? '',
      'authors': _authors(j['authors'] ?? j['author']),
      'categories': _asList(j['categories'] ?? j['tags']),
      'pdfUrl': _pdfUrl(j),
      'published': published, // ← Paper.fromJson에서 DateTime으로 파싱
      'year': j['year']?.toString(), // (없어도 됨, published에서 유도)
      'doi': j['doi'],
      'like_count': j['like_count'] ?? j['likeCount'] ?? 0,
      'is_liked': j['is_liked'] ?? j['isLiked'],
      'reviews': j['reviews'] ?? const [],
    };
  }
}
