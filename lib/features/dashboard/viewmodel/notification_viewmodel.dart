import 'package:flutter/foundation.dart';
import '../../../core/models/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  /// 더미 데이터
  List<NotificationModel> notifications = [
    NotificationModel(
      id: '1',
      title: '새로운 논문 추천',
      subtitle: '당신의 관심사에 맞는 새로운 논문이 추천되었습니다.',
      date: DateTime.now().subtract(Duration(hours: 5)),
    ),
    NotificationModel(
      id: '2',
      title: '폴더 업데이트',
      subtitle: '폴더에 새로운 논문이 추가되었습니다.',
      date: DateTime.now().subtract(Duration(days: 1)),
    ),
    // 추가적인 샘플 데이터
  ];

  bool get hasUnread {
    return notifications.any((n) => !n.read);
  }

  void markAllRead() {
    for (var n in notifications) n.read = true;
    notifyListeners();
  }

  void markRead(String id) {
    final n = notifications.firstWhere((x) => x.id == id);
    n.read = true;
    notifyListeners();
  }
}
