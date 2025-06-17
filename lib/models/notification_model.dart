// lib/models/notification_model.dart
class NotificationItem {
  final int id;
  final String message;
  final String type; // success, warning, info, error
  final String time;
  final bool isRead;
  final String? poolName;

  NotificationItem({
    required this.id,
    required this.message,
    required this.type,
    required this.time,
    required this.isRead,
    this.poolName,
  });

  // Helper method to create a copy with updated values
  NotificationItem copyWith({
    int? id,
    String? message,
    String? type,
    String? time,
    bool? isRead,
    String? poolName,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      message: message ?? this.message,
      type: type ?? this.type,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      poolName: poolName ?? this.poolName,
    );
  }
}
