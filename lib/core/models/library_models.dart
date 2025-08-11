import 'paper_model.dart';

enum LibrarySection { wantToRead, reading, completed, myPublications, private }

class LibraryItem {
  final Paper paper;
  final LibrarySection section;
  final bool isPrivate;

  LibraryItem({
    required this.paper,
    required this.section,
    this.isPrivate = false,
  });
}

/// 사용자 폴더
class LibraryFolder {
  final String id;
  final String name;
  final int count; // 서버 연동 전까지는 정적/로컬 카운트

  const LibraryFolder({required this.id, required this.name, this.count = 0});

  LibraryFolder copyWith({String? id, String? name, int? count}) {
    return LibraryFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
    );
  }
}
