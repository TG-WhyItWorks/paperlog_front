import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class AvatarMenu extends StatelessWidget {
  const AvatarMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Builder(
      builder: (btnContext) {
        return IconButton(
          icon: ClipOval(
            child: Image.network(
              auth.userAvatarUrl ?? '',
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/images/default_avatar.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          onPressed: () {
            // RenderBox로 아이콘 위치 계산
            final RenderBox button = btnContext.findRenderObject() as RenderBox;
            final overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;
            final pos = RelativeRect.fromRect(
              Rect.fromPoints(
                button.localToGlobal(Offset.zero, ancestor: overlay),
                button.localToGlobal(
                  button.size.bottomRight(Offset.zero),
                  ancestor: overlay,
                ),
              ),
              Offset.zero & overlay.size,
            );

            // 메뉴 항목
            final items = <PopupMenuEntry<String>>[
              if (!auth.isLoggedIn) ...[
                const PopupMenuItem(value: 'login', child: Text('로그인/회원가입')),
                const PopupMenuItem(value: 'settings', child: Text('설정')),
              ] else ...[
                const PopupMenuItem(value: 'profile', child: Text('내 프로필')),
                const PopupMenuItem(value: 'settings', child: Text('설정')),
                const PopupMenuItem(value: 'logout', child: Text('로그아웃')),
              ],
            ];

            // showMenu 호출
            showMenu<String>(
              context: btnContext,
              position: pos.shift(const Offset(0, 40)),
              items: items,
              color: Theme.of(context).cardColor,
              elevation: 4,
            ).then((value) {
              if (value == null) return;
              switch (value) {
                case 'login':
                  Navigator.of(context).pushNamed('/login');
                  break;
                case 'profile':
                  Navigator.of(context).pushNamed('/profile');
                  break;
                case 'settings':
                  Navigator.of(context).pushNamed('/settings');
                  break;
                case 'logout':
                  context.read<AuthViewModel>().signOut();
                  if (!context.mounted) return;
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                  break;
              }
            });
          },
        );
      },
    );
  }
}
