import 'package:paperlog_front/core/models/paper_model.dart';
import '../../../core/models/library_models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/token_storage.dart';
import '../../../core/config/api_config.dart';

class LibraryService {
  final _tokenStorage = TokenStorage();
  Map<String, String> _baseHeaders() => {
    ...ApiConfig.baseHeaders(),
    'Accept': 'application/json',
  };

  Future<Map<String, String>> _authHeaders() async {
    final at = await _tokenStorage.readAccessToken();
    if (at == null || at.isEmpty) return _baseHeaders();
    return {..._baseHeaders(), 'Authorization': 'Bearer $at'};
  }

  Future<List<LibraryItem>> fetchLibrary() async {
    final uri = ApiConfig.uri('/library');
    try {
      final res = await http
          .get(uri, headers: await _authHeaders())
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body) as List;
        return data.map<LibraryItem>((e) {
          final sectionStr = (e['section'] ?? '').toString();
          final paperJson = Map<String, dynamic>.from(
            e['paper'] as Map<Object?, Object?>,
          );
          return LibraryItem(
            paper: Paper.fromJson(paperJson),
            section: _parseSection(sectionStr),
            isPrivate: (e['is_private'] == true),
          );
        }).toList();
      }
      // 실패하면 샘플로 폴백
      return _fallbackSamples();
    } catch (_) {
      return _fallbackSamples();
    }
  }

  LibrarySection _parseSection(String s) {
    switch (s) {
      case 'wantToRead':
        return LibrarySection.wantToRead;
      case 'reading':
        return LibrarySection.reading;
      case 'completed':
        return LibrarySection.completed;
      case 'myPublications':
        return LibrarySection.myPublications;
      case 'private':
      default:
        return LibrarySection.private;
    }
  }

  List<LibraryItem> _fallbackSamples() {
    final samples = Paper.sampleList();
    return [
      LibraryItem(paper: samples[0], section: LibrarySection.wantToRead),
      LibraryItem(paper: samples[1], section: LibrarySection.reading),
      LibraryItem(paper: samples[2], section: LibrarySection.completed),
      LibraryItem(
        paper: samples[0].copyWith(id: 'pvt-1'),
        section: LibrarySection.private,
        isPrivate: true,
      ),
    ];
  }

  // 백엔드가 기대하는 섹션 문자열로 변환
  String _sectionToApi(LibrarySection s) {
    switch (s) {
      case LibrarySection.wantToRead:
        return 'wantToRead';
      case LibrarySection.reading:
        return 'reading';
      case LibrarySection.completed:
        return 'completed';
      case LibrarySection.myPublications:
        return 'myPublications';
      case LibrarySection.private:
        return 'private';
      case LibrarySection.none:
      default:
        return 'none';
    }
  }

  /// (서버 연동) 선택 논문들을 주어진 섹션으로 변경
  /// POST /library/section  (백엔드 라우트가 다르면 여기만 수정)
  Future<void> movePapersToSection({
    required List<String> ids,
    required LibrarySection section,
  }) async {
    final uri = ApiConfig.uri('/library/section');
    final body = json.encode({
      'paper_ids': ids,
      'section': _sectionToApi(section),
    });

    final res = await http
        .post(uri, headers: await _authHeaders(), body: body)
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('섹션 이동 실패: HTTP ${res.statusCode} ${res.body}');
    }
  }

  /// 선택 논문 삭제 (POST /library/papers/delete) 예시
  Future<void> deletePapers({required List<String> ids}) async {
    final uri = ApiConfig.uri('/library/papers/delete');
    final res = await http
        .post(
          uri,
          headers: await _authHeaders(),
          body: json.encode({'paper_ids': ids}),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('삭제 실패: HTTP ${res.statusCode} ${res.body}');
    }
  }
}
