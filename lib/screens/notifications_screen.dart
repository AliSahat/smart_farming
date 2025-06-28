// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Add this import
import '../models/notification_model.dart';
import '../providers/notification_provider.dart'; // Add this import
import '../widgets/notifications/notification_item_widget.dart';
import '../widgets/notifications/notification_filter_widget.dart';
import '../helper/notification_service.dart'; // Import notification service

class NotificationsScreen extends StatefulWidget {
  // Remove required parameters
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'semua';
  bool _showUnreadOnly = false;

  List<NotificationItem> _getFilteredNotifications(
    List<NotificationItem> notifications,
  ) {
    List<NotificationItem> filtered = List.from(notifications);

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

  @override
  Widget build(BuildContext context) {
    // Use Consumer to access the NotificationProvider
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final notifications = notificationProvider.notifications;
        final filteredNotifications = _getFilteredNotifications(notifications);
        final unreadCount = notifications.where((item) => !item.isRead).length;

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
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$unreadCount',
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
              if (unreadCount > 0)
                TextButton(
                  onPressed: () => _markAllAsRead(notificationProvider),
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
                onClearAll: () => _clearAllNotifications(notificationProvider),
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
                      notifications.length.toString(),
                      Icons.notifications,
                      Colors.blue,
                    ),
                    Container(height: 40, width: 1, color: Colors.grey[300]),
                    _buildStatItem(
                      'Belum Dibaca',
                      unreadCount.toString(),
                      Icons.mark_email_unread,
                      Colors.red,
                    ),
                    Container(height: 40, width: 1, color: Colors.grey[300]),
                    _buildStatItem(
                      'Peringatan',
                      notifications
                          .where(
                            (n) => n.type == 'warning' || n.type == 'error',
                          )
                          .length
                          .toString(),
                      Icons.warning,
                      Colors.orange,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: filteredNotifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredNotifications.length,
                        itemBuilder: (context, index) {
                          return NotificationItemWidget(
                            notification: filteredNotifications[index],
                            onTap: () => _markAsRead(
                              notificationProvider,
                              filteredNotifications[index],
                            ),
                            onDismiss: () => _dismissNotification(
                              notificationProvider,
                              filteredNotifications[index],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
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

  void _markAsRead(
    NotificationProvider provider,
    NotificationItem notification,
  ) {
    provider.markAsRead(notification.id);
  }

  void _markAllAsRead(NotificationProvider provider) {
    provider.markAllAsRead();

    // Get notification service and show notification in system bar
    final notificationService = Provider.of<NotificationService>(
      context,
      listen: false,
    );

    notificationService.showInfoNotification(
      'Notifikasi Dibaca',
      'Semua notifikasi telah ditandai sebagai sudah dibaca',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai sebagai sudah dibaca'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _dismissNotification(
    NotificationProvider provider,
    NotificationItem notification,
  ) {
    // Keep a copy for potential restore
    final removedNotification = notification;

    // Remove the notification
    provider.removeNotification(notification.id);

    // Get notification service and show notification in system bar
    final notificationService = Provider.of<NotificationService>(
      context,
      listen: false,
    );

    notificationService.showInfoNotification(
      'Notifikasi Dihapus',
      'Notifikasi "${notification.message}" telah dihapus',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notifikasi dihapus'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Batal',
          textColor: Colors.white,
          onPressed: () {
            // Restore notification
            provider.addNotification(removedNotification);

            // Notify that notification has been restored
            notificationService.showInfoNotification(
              'Notifikasi Dikembalikan',
              'Notifikasi "${notification.message}" telah dikembalikan',
            );
          },
        ),
      ),
    );
  }

  void _clearAllNotifications(NotificationProvider provider) {
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
              provider.clearAll();

              // Get notification service and show notification in system bar
              final notificationService = Provider.of<NotificationService>(
                context,
                listen: false,
              );

              notificationService.showInfoNotification(
                'Notifikasi Dihapus',
                'Semua notifikasi telah dihapus dari daftar',
              );

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
