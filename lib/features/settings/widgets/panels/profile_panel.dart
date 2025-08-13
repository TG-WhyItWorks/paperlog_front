import 'package:flutter/material.dart';
import '../setting_card.dart';

class ProfilePanel extends StatelessWidget {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return ListView(
      children: [
        SettingCard(
          title: '프로필',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이름, 소개, 아바타 등은 프로필 화면에서 수정할 수 있어요.', style: t.bodySmall),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).pushNamed('/profile'),
                child: const Text('프로필로 이동'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
