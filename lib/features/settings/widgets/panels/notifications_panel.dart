import 'package:flutter/material.dart';
import '../setting_card.dart';
import '../on_off_row.dart';

class NotificationsPanel extends StatefulWidget {
  const NotificationsPanel({super.key});

  @override
  State<NotificationsPanel> createState() => NotificationsPanelState();
}

class NotificationsPanelState extends State<NotificationsPanel> {
  bool directOn = false;
  bool relevantOn = false;
  bool pushOn = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SettingCard(
          title: '다이렉트 알림',
          subtitle: '댓글/멘션/팔로우 중인 논문 활동을 이메일로 받아요.',
          child: OnOffRow(
            value: directOn,
            onChanged: (v) => setState(() => directOn = v),
          ),
        ),
        SettingCard(
          title: '관련 토론',
          subtitle: '관심 주제의 주간 트렌딩 토론을 이메일로 받아요.',
          child: OnOffRow(
            value: relevantOn,
            onChanged: (v) => setState(() => relevantOn = v),
          ),
        ),
        SettingCard(
          title: '푸시 알림',
          subtitle: '브라우저 푸시 권한이 필요할 수 있어요.',
          child: OnOffRow(
            value: pushOn,
            onChanged: (v) => setState(() => pushOn = v),
          ),
        ),
      ],
    );
  }
}
