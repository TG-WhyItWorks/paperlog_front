import 'package:flutter/material.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class SidebarWidget extends StatelessWidget{
  final MainViewModel viewModel;
  const SidebarWidget({required this.viewModel, Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      color: Colors.white,
      child: ListView(
        children: viewModel.folders
          .map((folder)=>ListTile(
              title: Text(folder.name),
              trailing: Text('${folder.paperCount}'),
              onTap:() => viewModel.selectFolder(folder),
            ))
            .toList(),
      ),
    );
  }
}