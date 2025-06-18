import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/notification_model.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationItemWidget({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead ? Colors.grey[200]! : Colors.blue[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTypeColor(notification.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getTypeIcon(notification.type),
              color: _getTypeColor(notification.type),
              size: 20,
            ),
          ),
          title: Text(
            notification.message,
            style: TextStyle(
              fontWeight: notification.isRead
                  ? FontWeight.normal
                  : FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (notification.poolName != null) ...[
                const SizedBox(height: 4),
                Text(
                  notification.poolName!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                notification.time,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}
