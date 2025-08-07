import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/explore_viewmodel.dart';
import '../widgets/paper_card.dart';
import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';
import '../../dashboard/widgets/recommend_paper_card.dart';
import '../../../core/models/paper_model.dart';

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
      context.read<ExploreViewmodel>().search(widget.initialQuery);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: '논문을 검색해 보세요',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: const Icon(Icons.search),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (q) {
                        final query = q.trim();
                        context.read<ExploreViewmodel>().search(query);
                      },
                    ),
                  ),
                  Expanded(
                    child: Consumer<ExploreViewmodel>(
                      builder: (_, vm, __) {
                        if (!vm.hasSearched) {
                          final recs = Paper.sampleList();
                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: recs.length,
                            itemBuilder: (_, i) =>
                                RecommendPaperCard(paper: recs[i]),
                          );
                        }
                        if (vm.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (vm.errorMessage != null) {
                          final recs = Paper.sampleList();
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text('검색에 실패했습니다.'),
                              ),
                              const Divider(),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('이런 논문은 어떠세요?'),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: recs.length,
                                  itemBuilder: (_, i) =>
                                      RecommendPaperCard(paper: recs[i]),
                                ),
                              ),
                            ],
                          );
                        }

                        if (vm.papers.isEmpty) {
                          final recs = Paper.sampleList();
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text('검색 결과가 없습니다.'),
                              ),
                              const Divider(),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('이런 논문은 어떠세요?'),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: recs.length,
                                  itemBuilder: (_, i) =>
                                      RecommendPaperCard(paper: recs[i]),
                                ),
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
