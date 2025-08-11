import 'package:paperlog_front/core/models/paper_model.dart';
import '../../../core/models/library_models.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class LibraryService {
  // dart-define으로 주입: flutter run -d chrome --dart-define=API_URL=https://daf1d4db1de5.ngrok-free.app
  static const _baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000',
  );

  Future<List<LibraryItem>> fetchLibrary() async {
    final uri = Uri.parse('$_baseUrl/library'); // FastAPI: GET /library
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final List data = json.decode(res.body) as List;
        return data.map<LibraryItem>((e) {
          final sectionStr = (e['section'] ?? '').toString();
          final paperJson = (e['paper'] as Map).cast<String, dynamic>();
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

  /// Private PDF 업로드 (FastAPI: POST /private-papers/upload)
  Future<Paper> uploadPrivatePdf({
    required String filename,
    required Uint8List bytes,
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse('$_baseUrl/private-papers/upload');
    final req = http.MultipartRequest('POST', uri);
    if (fields != null) req.fields.addAll(fields);

    //final mime = lookupMimeType(filename) ?? 'application/pdf';
    //final parts = mime.split('/');

    req.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: filename,
        //contentType: MediaType(parts.first, parts.last),
      ),
    );

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('업로드 실패: HTTP ${res.statusCode}');
    }
    final map = json.decode(res.body) as Map<String, dynamic>;
    return Paper.fromJson(map);
  }
}
