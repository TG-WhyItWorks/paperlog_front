import 'paper_model.dart';

enum LibrarySection {
  wantToRead,
  reading,
  completed,
  myPublications,
  private,
  none,
}

class LibraryItem {
  final Paper paper;
  final LibrarySection section;
  final bool isPrivate;
  final String? parentId;

  LibraryItem({
    required this.paper,
    required this.section,
    this.isPrivate = false,
    this.parentId,
  });
}

/// 사용자 폴더
class LibraryFolder {
  final String id;
  final String name;
  final int count;
  final String? parentId;

  const LibraryFolder({
    required this.id,
    required this.name,
    this.count = 0,
    this.parentId,
  });

  LibraryFolder copyWith({String? id, String? name, int? count}) {
    return LibraryFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      parentId: parentId ?? this.parentId,
    );
  }
}
