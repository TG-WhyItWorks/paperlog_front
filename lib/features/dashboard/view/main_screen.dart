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
    vm.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    vm.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          HeaderWidget(viewModel: vm),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (vm.isSidebarOpen) SidebarWidget(viewModel: vm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: vm.recommendPapers
                          .map((paper) => RecommendPaperCard(paper: paper))
                          .toList(),
                    ),
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
