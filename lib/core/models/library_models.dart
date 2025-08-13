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

  // 라이브러리 목록 항목
  LibraryItem({
    required this.paper,
    required this.section,
    this.isPrivate = false,
    this.parentId,
  });
}
