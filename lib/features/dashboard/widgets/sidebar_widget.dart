import 'package:flutter/material.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class SidebarWidget extends StatelessWidget {
  final MainViewModel viewModel;
  const SidebarWidget({required this.viewModel, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        children: viewModel.folders
            .map(
              (folder) => ListTile(
                title: Text(
                  folder.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Text(
                  '${folder.paperCount}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onTap: () => viewModel.selectFolder(folder),
              ),
            )
            .toList(),
      ),
    );
  }
}
