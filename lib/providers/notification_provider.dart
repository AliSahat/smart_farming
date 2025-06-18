import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification); // Insert di awal list

    // Batasi jumlah notifikasi (maksimal 100)
    if (_notifications.length > 100) {
      _notifications.removeRange(100, _notifications.length);
    }

    notifyListeners();

    // Debug log
    debugPrint('Notification added: ${notification.message}');
    debugPrint('Total notifications: ${_notifications.length}');
  }

  void markAsRead(String id) {
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

  void removeNotification(String id) {
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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Peringatan Sistem',
        message: 'Level air kolam ikan terlalu rendah',
        type: 'warning',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        poolName: 'Kolam Ikan',
      ),
      NotificationItem(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        title: 'Status Normal',
        message: 'Sistem berhasil terhubung ke sensor',
        type: 'success',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        poolName: 'Kolam Ikan',
      ),
      NotificationItem(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        title: 'Informasi Sistem',
        message: 'Pemeliharaan rutin sistem dimulai',
        type: 'info',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        poolName: 'Kolam Udang',
      ),
    ];

    for (final notification in testNotifications) {
      addNotification(notification);
    }
  }
}
