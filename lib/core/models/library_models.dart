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
