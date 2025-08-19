import 'package:flutter/material.dart';
import 'package:paperlog_front/features/explore/widgets/explore_search_input.dart';
import 'package:provider/provider.dart';
import '../viewmodel/explore_viewmodel.dart';
import '../widgets/paper_card.dart';
import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../../dashboard/widgets/recommend_paper_card.dart';
import '../../../core/models/paper_model.dart';
import '../../paper/widgets/recommended_papers_list.dart';

class ExplorePage extends StatefulWidget {
  final String initialQuery;
  const ExplorePage({Key? key, required this.initialQuery}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreViewModel>().search(widget.initialQuery);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MainViewModel>();
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
            const SidebarWidget(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              width: 1,
              color: vm.isSidebarOpen
                  ? Theme.of(context).dividerColor
                  : Colors.transparent,
            ),
            Expanded(
              child: Column(
                children: [
                  ExploreSearchInput(controller: _searchController),
                  Expanded(
                    child: Consumer<ExploreViewModel>(
                      builder: (_, vm, __) {
                        if (!vm.hasSearched) {
                          return ListView(
                            padding: const EdgeInsets.all(16),
                            children: const [
                              Text(
                                '지금 인기 있는 논문',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              RecommendedPapersList(
                                category: 'trending',
                                limit: 6,
                              ),
                            ],
                          );
                        }
                        if (vm.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (vm.errorMessage != null) {
                          return ListView(
                            padding: const EdgeInsets.all(16),
                            children: const [
                              Text('검색에 실패했습니다.'),
                              Divider(),
                              SizedBox(height: 8),
                              Text('이런 논문은 어떠세요?'),
                              SizedBox(height: 12),
                              RecommendedPapersList(
                                category: 'trending',
                                limit: 6,
                              ),
                            ],
                          );
                        }

                        if (vm.papers.isEmpty) {
                          return ListView(
                            padding: const EdgeInsets.all(16),
                            children: const [
                              Text('검색 결과가 없습니다.'),
                              Divider(),
                              SizedBox(height: 8),
                              Text('이런 논문은 어떠세요?'),
                              SizedBox(height: 12),
                              RecommendedPapersList(
                                category: 'trending',
                                limit: 6,
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          itemCount: vm.papers.length,
                          itemBuilder: (_, index) =>
                              PaperCard(paper: vm.papers[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
