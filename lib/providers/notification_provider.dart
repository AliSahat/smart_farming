import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification(NotificationItem notification) {
    _notifications.add(notification);
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
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  void updateNotifications(List<NotificationItem> updatedNotifications) {
    _notifications.clear();
    _notifications.addAll(updatedNotifications);
    notifyListeners();
  }

  void removeNotification(int id) {
    _notifications.removeWhere((notification) => notification.id == id);
    notifyListeners();
  }
}
