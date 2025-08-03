import 'package:flutter/material.dart';
import 'package:paperlog_front/features/dashboard/viewmodel/dashboard_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../../core/models/profile_model.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../widgets/profile_avatar_widget.dart';
import '../widgets/profile_stat_widget.dart';
import '../../dashboard/widgets/header_widget.dart';
import '../../dashboard/widgets/sidebar_widget.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewmodel()..loadProfile(),
      child: Consumer<ProfileViewmodel>(
        builder: (context, vm, _) {
          final profile = vm.profile;
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: const HeaderWidget(),
            ),

            body: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (context.watch<MainViewModel>().isSidebarOpen)
                    SidebarWidget(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: LayoutBuilder(
                        builder: (context, cons) {
                          final isWeb = cons.maxWidth > 600;
                          final avatarSize = isWeb ? 150.0 : 80.0;
                          return Center(
                            child: Card(
                              margin: EdgeInsets.all(16.0),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 32,
                                ),
                                child: isWeb
                                    ? Row(
                                        children: _buildContent(
                                          profile,
                                          avatarSize,
                                          vm,
                                          context,
                                        ),
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: _buildContent(
                                          profile,
                                          avatarSize,
                                          vm,
                                          context,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(
    ProfileModel profile,
    double avatarSize,
    ProfileViewmodel vm,
    BuildContext context,
  ) {
    return [
      ProfileAvatar(avatarUrl: profile.avatarUrl, size: avatarSize),
      SizedBox(width: 24, height: 24),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.username,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8),
            Text(profile.bio),
            SizedBox(height: 16),
            Row(
              children: [
                ProfileStat(label: '팔로워', count: int.parse(profile.followers)),
                SizedBox(height: 16),
                ProfileStat(label: '팔로윙', count: int.parse(profile.following)),
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showEditBioDialog(context, vm),
              child: Text('프로필 수정'),
            ),
          ],
        ),
      ),
    ];
  }

  void _showEditBioDialog(BuildContext context, ProfileViewmodel vm) {
    final TextEditingController controller = TextEditingController(
      text: vm.profile.bio,
    );
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('자기소개 수정'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(hintText: '새로운 자기 소개를 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                vm.updateBio(controller.text);
                Navigator.of(context).pop();
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }
}
