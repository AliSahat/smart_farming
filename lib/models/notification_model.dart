// lib/models/notification_model.dart
class NotificationItem {
  final int id;
  final String message;
  final String type; // 'success', 'warning', 'info', 'error'
  final String time;
  final bool isRead;
  final String? poolName;

  NotificationItem({
    required this.id,
    required this.message,
    required this.type,
    required this.time,
    this.isRead = false,
    this.poolName,
  });
}
