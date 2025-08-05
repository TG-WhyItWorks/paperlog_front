import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();
    return Container(
      width: 320,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Library',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...viewModel.folders.map(
              (folder) => ListTile(
                contentPadding: EdgeInsets.zero,
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
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Folders',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.add,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    //TODO: 폴더 추가 로직
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 예시용 정적 리스트
            // TODO: 추후 viewModel.customFolders로 대체
            ...[
              {'name': 'Machine Learning', 'count': 5},
              {'name': 'Flutter Development', 'count': 3},
              {'name': 'Data Science', 'count': 8},
            ].map(
              (data) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  data['name'] as String,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  '${data['count']} papers',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).iconTheme.color,
                ),
                onTap: () {
                  //TODO: 사용자 폴더 클릭 핸들러
                },
              ),
            ),
            const Divider(),

            Text(
              'Blog',
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            //예시용 블로그 리스트
            ...[
              {'name': 'Interesting Blog', 'count': 12},
              {'name': 'Interesting Post', 'count': 64},
            ].map(
              (data) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  data['name'] as String,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                trailing: Text(
                  '${data['count']} posts',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  //TODO: 블로그 클릭 핸들러
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
