import 'package:flutter/material.dart';
import 'package:paperlog_front/features/paper/widgets/paper_breadcrumb.dart';
import 'package:paperlog_front/features/paper/widgets/paper_header.dart';
import 'package:paperlog_front/features/paper/widgets/paper_tabs.dart';
import 'package:provider/provider.dart';
import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../viewmodel/paper_detail_viewmodel.dart';
import '../widgets/blog_post_card.dart';
import '../widgets/recommended_papers_list.dart';
import '../../../core/models/paper_model.dart';
import 'package:paperlog_front/features/paper/widgets/paper_review_list.dart';

class PaperDetailPage extends StatefulWidget {
  final String paperId;
  const PaperDetailPage({Key? key, required this.paperId}) : super(key: key);

  @override
  _PaperDetailedPageState createState() => _PaperDetailedPageState();
}

class _PaperDetailedPageState extends State<PaperDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _trackedRecent = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PaperDetailViewModel>().loadDetail(widget.paperId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaperDetailViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: HeaderWidget(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (context.watch<MainViewModel>().isSidebarOpen) SidebarWidget(),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: Theme.of(context).dividerColor,
            ),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.error != null
                  ? Center(child: Text('오류 발생: ${vm.error}'))
                  : _buildContent(context, vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PaperDetailViewModel vm) {
    final detail = vm.detail!;

    // ✅ 최근 본 논문 기록(한 번만)
    if (!_trackedRecent) {
      final p = Paper(
        id: detail.id,
        title: detail.title,
        authors: detail.authors,
        year: detail.year,
        fields: detail.fields,
        pdfUrl: detail.pdfUrl,
        abstractText: detail.abstractText,
        translatedAbstract: detail.translatedAbstract,
        blogSummary: detail.blogSummary,
        relatedBlogs: detail.relatedBlogs, // (List<BlogReviewSummary>) OK
        doi: detail.doi,
        likeCount: detail.likeCount,
        isLiked: detail.isLiked,
        publishedAt: null, // 필요시 서버 값으로 세팅
      );
      context.read<MainViewModel>().viewedPaper(p);
      _trackedRecent = true;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: ConstrainedBox(
            // ✅ 스크롤 영역의 가로폭을 강제: 자식 Column이 전체 폭을 사용
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PaperBreadcrumb(),
                const SizedBox(height: 16),

                // 제목/메타/다운로드
                PaperHeader(
                  title: detail.title,
                  authors: detail.authors,
                  year: detail.year,
                  fields: detail.fields,
                  pdfUrl: detail.pdfUrl,
                ),

                const SizedBox(height: 24),

                //(추상/번역/요약) 탭
                PaperTabs(
                  abstractText: detail.abstractText,
                  translatedAbstract: detail.translatedAbstract,
                  blogSummary: detail.blogSummary,
                  height: 300,
                ),

                const SizedBox(height: 32),
                // 🔽 추가: 이 논문 리뷰(좋아요 많은 순)
                Text(
                  'Review Blogs (Top Likes)',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                PaperReviewList(paperTitle: detail.title, limit: 10),
                const SizedBox(height: 8),

                // 🔽 추가: 더보기(검색 탭으로 이동)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        '/blogs',
                        arguments: {
                          'tab': 'search', // 검색 탭으로 열기
                          'keyword': detail.title, // 논문 제목으로 검색
                          'orderByVotes': true, // 좋아요순
                        },
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('더보기'),
                  ),
                ),

                // const SizedBox(height: 24),

                // //블로그 추천
                // Text(
                //   'Related Blog Posts',
                //   style: Theme.of(
                //     context,
                //   ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                // ),

                // const SizedBox(height: 12),
                // ...detail.relatedBlogs.map((b) => BlogPostCard(blog: b)),
                // const SizedBox(height: 12),
                // // 이 논문과 연관된 카테고리 기반 추천 (없으면 'trending')
                // RecommendedPapersList(
                //   category: detail.fields.isNotEmpty ? detail.fields.first : 'cs.AI',
                //   limit: 6,
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
