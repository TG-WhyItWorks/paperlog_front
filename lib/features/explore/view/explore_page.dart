import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/explore_viewmodel.dart';
import '../widgets/paper_card.dart';
import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initialQuery =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return ChangeNotifierProvider(
      create: (_) => ExploreViewmodel()..search(initialQuery ?? ''),
      child: Scaffold(
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
                        decoration: InputDecoration(
                          hintText: '논문을 검색해 보세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: const Icon(Icons.search),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: context.read<ExploreViewmodel>().search,
                      ),
                    ),
                    Expanded(
                      child: Consumer<ExploreViewmodel>(
                        builder: (contxt, vm, _) {
                          if (vm.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (vm.errorMessage != null) {
                            return Center(
                              child: Text('오류 발생: ${vm.errorMessage}'),
                            );
                          }

                          if (vm.papers.isEmpty) {
                            return const Center(child: Text('검색 결과가 없습니다.'));
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
      ),
    );
  }
}
