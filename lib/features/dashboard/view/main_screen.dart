import 'package:flutter/material.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import '../widgets/header_widget.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/searchbar_widget.dart';
import '../widgets/recommend_paper_card.dart';
import '../widgets/folder_list_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final MainViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = MainViewModel();
  }

  @override
  Widget build(BuildContext context) {
    final vm = MainViewModel();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          SidebarWidget(viewModel: vm),
          Expanded(
            child: Column(
              children: [
                HeaderWidget(viewModel: vm),
                SearchbarWidget(viewModel: vm),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: vm.recommendPapers
                        .map((paper) => RecommendPaperCard(paper: paper))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
