// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../widgets/notifications/notification_item_widget.dart';
import '../widgets/notifications/notification_filter_widget.dart';

class NotificationsScreen extends StatefulWidget {
  final List<NotificationItem> notifications;
  final Function(List<NotificationItem>) onNotificationsUpdated;

  const NotificationsScreen({
    super.key,
    required this.notifications,
    required this.onNotificationsUpdated,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'semua';
  bool _showUnreadOnly = false;

  List<NotificationItem> get _filteredNotifications {
    List<NotificationItem> filtered = List.from(widget.notifications);

    if (_showUnreadOnly) {
      filtered = filtered.where((item) => !item.isRead).toList();
    }

    if (_selectedFilter != 'semua') {
      filtered = filtered
          .where((item) => item.type == _selectedFilter)
          .toList();
    }

    return filtered;
  }

  int get _unreadCount {
    return widget.notifications.where((item) => !item.isRead).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Tandai Semua'),
            ),
        ],
      ),
      body: Column(
        children: [
          NotificationFilterWidget(
            selectedFilter: _selectedFilter,
            showUnreadOnly: _showUnreadOnly,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
            onUnreadToggle: (value) {
              setState(() {
                _showUnreadOnly = value;
              });
            },
            onClearAll: _clearAllNotifications,
          ),

          // Statistics
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  widget.notifications.length.toString(),
                  Icons.notifications,
                  Colors.blue,
                ),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                _buildStatItem(
                  'Belum Dibaca',
                  _unreadCount.toString(),
                  Icons.mark_email_unread,
                  Colors.red,
                ),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                _buildStatItem(
                  'Peringatan',
                  widget.notifications
                      .where((n) => n.type == 'warning' || n.type == 'error')
                      .length
                      .toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      return NotificationItemWidget(
                        notification: _filteredNotifications[index],
                        onTap: () => _markAsRead(_filteredNotifications[index]),
                        onDismiss: () =>
                            _dismissNotification(_filteredNotifications[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi dari sistem akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _markAsRead(NotificationItem notification) {
    final updatedNotifications = widget.notifications.map((n) {
      if (n.id == notification.id) {
        return NotificationItem(
          id: n.id,
          message: n.message,
          type: n.type,
          time: n.time,
          isRead: true,
          poolName: n.poolName,
        );
      }
      return n;
    }).toList();

    widget.onNotificationsUpdated(updatedNotifications);
  }

  void _markAllAsRead() {
    final updatedNotifications = widget.notifications.map((n) {
      return NotificationItem(
        id: n.id,
        message: n.message,
        type: n.type,
        time: n.time,
        isRead: true,
        poolName: n.poolName,
      );
    }).toList();

    widget.onNotificationsUpdated(updatedNotifications);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai sebagai sudah dibaca'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _dismissNotification(NotificationItem notification) {
    final updatedNotifications = widget.notifications
        .where((n) => n.id != notification.id)
        .toList();

    widget.onNotificationsUpdated(updatedNotifications);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifikasi dihapus'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Batal',
          textColor: Colors.white,
          onPressed: () {
            // Restore notification
            final restoredNotifications = List<NotificationItem>.from(
              widget.notifications,
            );
            widget.onNotificationsUpdated(restoredNotifications);
          },
        ),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi'),
        content: const Text(
          'Yakin ingin menghapus semua notifikasi? Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              widget.onNotificationsUpdated([]);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua notifikasi dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
