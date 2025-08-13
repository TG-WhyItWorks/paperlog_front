class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  bool read;

  // 알림 엔티티 (읽음 상태 포함)
  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    this.read = false,
  });
}
