import 'package:flutter/material.dart';
import 'package:paperlog_front/features/settings/widgets/setting_card.dart';
import '../mini_input.dart';

class ConnectionsPanel extends StatelessWidget {
  const ConnectionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SettingCard(
          title: '소셜 링크',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              MiniInput(label: 'GitHub 사용자명'),
              MiniInput(label: 'X(Twitter) 사용자명'),
              MiniInput(label: 'LinkedIn 사용자명'),
              MiniInput(label: 'Bluesky 핸들'),
              MiniInput(label: '공개 이메일'),
            ],
          ),
        ),
        SettingCard(
          title: 'Academic Profiles',
          subtitle: 'ORCID, Google Scholar 연동으로 퍼블리케이션을 자동 임포트해요.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('Connect ORCID'),
              ),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Connect Scholar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
