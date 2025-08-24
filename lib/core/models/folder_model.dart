// class Folder {
//   final String id;
//   final String name;
//   final String? parentId;
//   int paperCount;

//   Folder({
//     required this.id,
//     required this.name,
//     this.parentId,
//     this.paperCount = 0,
//   });

//   ///기본 폴더
//   ///TODO: 배포시
//   static List<Folder> defaultFolders() {
//     return [
//       Folder(id: 'favorite', name: 'Favorites', paperCount: 15),
//       Folder(id: 'to_read', name: 'To Read', paperCount: 20),
//       Folder(id: 'read', name: 'Read', paperCount: 120),
//     ];
//   }
// }

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

  LibraryFolder copyWith({
    String? id,
    String? name,
    int? count,
    String? parentId,
  }) {
    return LibraryFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
      parentId: parentId ?? this.parentId,
    );
  }
}
