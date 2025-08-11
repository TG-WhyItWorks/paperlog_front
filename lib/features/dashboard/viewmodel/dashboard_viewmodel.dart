import 'package:flutter/foundation.dart';
import '../../../core/models/paper_model.dart';
import '../../../core/models/folder_model.dart';

enum PageType { home, explore, library, blog }

class MainViewModel extends ChangeNotifier {
  List<Paper> recommendPapers = [];
  List<Folder> folders = [];

  List<Paper> recentPapers = <Paper>[];
  List<BlogPostSummary> recentBlogs = <BlogPostSummary>[];

  void viewedPaper(Paper p) {
    _pushUnique<Paper>(recentPapers, p, (x) => x.id ?? '');
    notifyListeners();
  }

  void viewedBlog(BlogPostSummary b) {
    _pushUnique<BlogPostSummary>(recentBlogs, b, (x) => x.url);
    notifyListeners();
  }

  void _pushUnique<T>(List<T> list, T item, String Function(T) keyOf) {
    final k = keyOf(item);
    list.removeWhere((e) => keyOf(e) == k);
    list.insert(0, item);
    if (list.length > 20) list.removeLast();
  }

  /// 사이드바 열림 상태
  bool isSidebarOpen = true;

  /// 현재 선택된 페이지
  PageType currentPage = PageType.home;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  MainViewModel() {
    _loadInitialData();
    _loadRecommendedPapers();
  }

  void _loadRecommendedPapers() {
    //샘플 데이터 또는 API 호출 결과를 here에 할당
    recommendPapers = Paper.sampleList();
    notifyListeners();
  }

  void _loadInitialData() {
    //TODO: API 호출 또는 더미 데이터
    recommendPapers = Paper.sampleList();
    folders = Folder.defaultFolders();
    notifyListeners();
  }

  void selectFolder(Folder folder) {
    //TODO: 선택 폴더에 맞추어 papers 필터링
    notifyListeners();
  }

  /// 사이드바 열기/닫기 토글
  void toggleSidebar() {
    isSidebarOpen = !isSidebarOpen;
    notifyListeners();
  }

  /// 페이지 변경
  void navigationTo(PageType page) {
    currentPage = page;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    if (_searchQuery != q) {
      _searchQuery = q;
      notifyListeners();
    }
  }
}

// 간단한 블로그 요약 VO (필요하면 본인 모델로 교체)
class BlogPostSummary {
  final String title;
  final String url;
  final String? source; // 도메인/블로그명 등
  BlogPostSummary({required this.title, required this.url, this.source});
}
