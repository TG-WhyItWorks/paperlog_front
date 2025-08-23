import 'package:flutter/foundation.dart';
import '../../../core/models/paper_model.dart';
import '../../../core/models/review_models.dart';
import '../../paper/service/paper_recommend_service.dart';

enum PageType { home, explore, library, blog }

class MainViewModel extends ChangeNotifier {
  List<Paper> recommendPapers = [];

  List<Paper> recentPapers = <Paper>[];
  List<BlogReviewSummary> recentBlogs = <BlogReviewSummary>[];

  final _recSvc = PaperRecommendService();

  //사용자가 본 논문을 최근 목록에 쌓기(중복 제거 + 최대 20개)
  void viewedPaper(Paper p) {
    _pushUnique<Paper>(recentPapers, p, (x) => x.id);
    notifyListeners();
  }

  //사용자가 본 블로그를 최근 목록에 쌓기(중복 제거 + 최대 20개)
  void viewedBlog(BlogReviewSummary b) {
    _pushUnique<BlogReviewSummary>(recentBlogs, b, (x) => '${x.id}');
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

  //추천 논문 목록
  Future<void> _loadRecommendedPapers() async {
    try {
      final list = await _recSvc.topByCategory('trending', limit: 6);
      recommendPapers = list;
    } catch (_) {
      recommendPapers = [];
    }
    notifyListeners();
  }

  void _loadInitialData() {
    recommendPapers = [];
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
