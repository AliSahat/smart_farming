import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(int id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void removeNotification(int id) {
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void addTestNotifications() {
    final testNotifications = [
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch,
        message: 'Level air kolam ikan terlalu rendah',
        type: 'warning',
        time: '10:30 18/06/2025',
        poolName: 'Kolam Ikan',
      ),
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch + 1,
        message: 'Sistem berhasil terhubung ke sensor',
        type: 'success',
        time: '10:25 18/06/2025',
        isRead: true,
      ),
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch + 2,
        message: 'Kran air otomatis dibuka',
        type: 'info',
        time: '10:20 18/06/2025',
        poolName: 'Aquarium',
      ),
    ];

    for (var notification in testNotifications.reversed) {
      _notifications.insert(0, notification);
    }
    notifyListeners();
  }
}
