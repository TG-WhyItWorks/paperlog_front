class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    this.read = false,
  });
}
