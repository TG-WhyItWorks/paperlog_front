class Folder {
  final String id;
  final String name;
  final String? parentId;
  int paperCount;

  Folder({
    required this.id,
    required this.name,
    this.parentId,
    this.paperCount = 0,
  });

  ///기본 폴더 반환
  static List<Folder> defaultFolders() {
    return [
      Folder(id: 'favorite', name: 'Favorites', paperCount: 15),
      Folder(id: 'to_read', name: 'To Read', paperCount: 20),
      Folder(id: 'read', name: 'Read', paperCount: 120),
    ];
  }

  ///사용자 정의 폴더 예시
  static List<Folder> customFoldersSample() {
    return [
      Folder(id: 'cs', name: 'Computer Science'),
      Folder(id: 'cs_dl', name: 'Deep Learning', parentId: 'cs', paperCount: 5),
      Folder(
        id: 'cs_dl_attn',
        name: 'Attention is All You Need',
        parentId: 'cs_dl',
        paperCount: 1,
      ),
    ];
  }
}
