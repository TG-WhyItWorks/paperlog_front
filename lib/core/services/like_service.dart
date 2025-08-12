import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../../core/services/token_storage.dart';

// lib/core/services/like_service.dart
class LikeService {
  final _token = TokenStorage();

  Future<Set<String>> getMyLikedIds() async {
    final uri = ApiConfig.uri('/api/arxiv/users/liked');
    final r = await http.get(uri, headers: await _auth());
    if (r.statusCode != 200) throw Exception(r.body);
    final data = json.decode(r.body);
    // ["1302.5977","..."] 혹은 {items:[...]} 둘 다 대응
    final list = (data is List) ? data : (data['items'] as List? ?? const []);
    return list.map((e) => e.toString()).toSet();
  }

  Future<int> getLikeCount(String id) async {
    final uri = ApiConfig.uri(
      '/api/arxiv/${Uri.encodeComponent(id)}/like-count',
    );
    final r = await http.get(uri, headers: await _auth());
    if (r.statusCode != 200) throw Exception(r.body);
    final data = json.decode(r.body);
    return (data is int)
        ? data
        : (data['likeCount'] ?? data['count'] ?? 0) as int;
  }

  Future<int> like(String id) async {
    final uri = ApiConfig.uri(
      '/api/arxiv/${Uri.encodeComponent(id)}/like',
    ); // 또는 /api/arxiv/likes
    final r = await http.post(uri, headers: await _auth());
    if (r.statusCode != 200 && r.statusCode != 201 && r.statusCode != 409) {
      throw Exception(r.body);
    }
    if (r.body.isEmpty) return -1;
    final d = json.decode(r.body);
    return (d['likeCount'] ?? d['count'] ?? -1)
        as int; // -1이면 서버가 카운트를 안 돌려준 경우
  }

  Future<int> unlike(String id) async {
    final uri = ApiConfig.uri(
      '/api/arxiv/${Uri.encodeComponent(id)}/like',
    ); // 또는 /api/arxiv/likes/{id}
    final r = await http.delete(uri, headers: await _auth());
    if (r.statusCode != 200 && r.statusCode != 204) {
      throw Exception(r.body);
    }
    if (r.body.isEmpty) return -1;
    final d = json.decode(r.body);
    return (d['likeCount'] ?? d['count'] ?? -1) as int;
  }

  Future<Map<String, String>> _auth() async {
    final at = await _token.readAccessToken();
    final h = ApiConfig.baseHeaders();
    return (at == null || at.isEmpty)
        ? h
        : {...h, 'Authorization': 'Bearer $at'};
  }
}
