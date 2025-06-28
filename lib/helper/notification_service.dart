// ignore_for_file: unused_import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

import '../models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationService {
  final NotificationProvider _notificationProvider;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int _notificationId = 0;

  NotificationService(this._notificationProvider);

  Future<void> initialize() async {
    Logger().i("Starting notification service initialization");

    // Request notification permission
    final PermissionStatus status = await Permission.notification.request();
    Logger().i("Notification permission status: $status");

    // Initialize settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    Logger().i("Android init settings configured with default icon");

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    Logger().i("iOS init settings configured with all permissions");

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    try {
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          Logger().i("Notification clicked: ${details.payload}");
        },
      );
      Logger().i("Notification plugin initialized successfully");
    } catch (e) {
      Logger().e("Failed to initialize notification plugin", error: e);
    }

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    // Create notification channels for Android
    if (Platform.isAndroid) {
      Logger().i("Creating Android notification channels");

      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidPlugin != null) {
        try {
          // Create system channel
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              'system_notifications',
              'System Notifications',
              description: 'Notifications about system status and events',
              importance: Importance.high,
            ),
          );
          Logger().i("System notification channel created");

          // Create valve channel
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              'valve_notifications',
              'Valve Notifications',
              description: 'Notifications about valve status changes',
              importance: Importance.high,
            ),
          );
          Logger().i("Valve notification channel created");

          // Create pump channel
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              'pump_notifications',
              'Pump Notifications',
              description: 'Notifications about pump status changes',
              importance: Importance.high,
            ),
          );
          Logger().i("Pump notification channel created");

          // Create test channel
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              'test_channel',
              'Test Channel',
              description: 'For testing notification delivery',
              importance: Importance.max,
            ),
          );
          Logger().i("Test notification channel created");

          // List all channels to verify
          final channels = await androidPlugin.getNotificationChannels();
          Logger().i("All channels: ${channels?.map((c) => c.id).join(', ')}");
        } catch (e) {
          Logger().e("Failed to create notification channels: $e");
        }
      } else {
        Logger().e("Android plugin implementation not found");
      }
    } else {
      Logger().i("Skipping channel creation (not on Android)");
    }
  }

  // Wrapper function untuk kompatibilitas dengan PoolProvider
  void addNotificationFromItem(NotificationItem notification) {
    // Use the addPoolNotification method to ensure it's shown in system notification bar
    addPoolNotification(notification);
    Logger().i(
      "Notification added both in-app and to system bar: ${notification.title} - ${notification.message}",
    );
  }

  Future<void> _showNotification(
    String title,
    String body,
    String channelId,
    String channelName,
  ) async {
    Logger().i(
      "📤 Showing notification: \"$title\" - \"$body\" on channel \"$channelId\"",
    );

    try {
      AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );
      Logger().d("Android notification details configured with high priority");

      NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      final id = _notificationId++;
      Logger().i("Using notification ID: $id");

      await _notificationsPlugin
          .show(id, title, body, platformDetails)
          .then((_) {
            Logger().i("✅ Notification #$id sent successfully");
          })
          .catchError((error) {
            Logger().e("❌ Failed to show notification #$id", error: error);
          });
    } catch (e) {
      Logger().e("❌ Error preparing notification", error: e);
    }
  }

  // Add debugging method
  Future<void> checkNotificationStatus() async {
    Logger().i("Checking notification permission status");
    final status = await Permission.notification.status;
    Logger().i("Current notification permission: $status");

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidPlugin != null) {
        try {
          final channels = await androidPlugin.getNotificationChannels();
          if (channels != null && channels.isNotEmpty) {
            Logger().i("Active channels (${channels.length}):");
            for (var channel in channels) {
              Logger().i(
                " - ${channel.id}: ${channel.name}, Importance: ${channel.importance}",
              );
            }
          } else {
            Logger().i("No notification channels found!");
          }
        } catch (e) {
          Logger().e("Error retrieving notification channels: $e");
        }
      }
    }
  }

  void addSystemNotification(String message, String type, {String? poolName}) {
    String title = 'Sistem Notifikasi';
    String body = poolName != null ? '$message pada $poolName' : message;
    Logger().i("Creating system notification: $title - $body");

    // Show system notification
    _showNotification(
      title,
      body,
      'system_notifications',
      'System Notifications',
    );

    _notificationProvider.addNotification(
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _getTitleByType(type),
        message: message,
        type: type,
        timestamp: DateTime.now(),
        poolName: poolName,
      ),
    );
    Logger().i("System notification created with type: $type");
  }

  void addValveNotification(
    bool isOpen,
    String contextInfo, {
    String type = 'info',
    String? poolName,
  }) {
    final status = isOpen ? 'TERBUKA' : 'TERTUTUP';
    final icon = isOpen ? '🟢' : '🔴';

    _notificationProvider.addNotification(
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Status Keran/Valve',
        message:
            '$icon Keran $status ($contextInfo) - ${poolName ?? 'Unknown'}',
        type: type,
        timestamp: DateTime.now(),
        poolName: poolName,
      ),
    );

    String title = 'Katup ${isOpen ? 'Dibuka' : 'Ditutup'}';
    String body =
        'Katup ${poolName != null ? 'pada $poolName ' : ''}${isOpen ? 'dibuka' : 'ditutup'} melalui $contextInfo';

    // Show system notification
    _showNotification(
      title,
      body,
      'valve_notifications',
      'Valve Notifications',
    );
  }

  void addPumpNotification(
    bool isRunning,
    String contextInfo, {
    String type = 'info',
    String? poolName,
  }) {
    final status = isRunning ? 'MENYALA' : 'MATI';
    final icon = isRunning ? '🔵' : '⚫';

    _notificationProvider.addNotification(
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Status Pompa',
        message:
            '$icon Pompa $status ($contextInfo) - ${poolName ?? 'Unknown'}',
        type: type,
        timestamp: DateTime.now(),
        poolName: poolName,
      ),
    );

    String title = 'Pompa ${isRunning ? 'Dinyalakan' : 'Dimatikan'}';
    String body =
        'Pompa ${poolName != null ? 'pada $poolName ' : ''}${isRunning ? 'diaktifkan' : 'dinonaktifkan'} melalui $contextInfo';

    // Show system notification
    _showNotification(title, body, 'pump_notifications', 'Pump Notifications');
  }

  void addWaterLevelNotification(
    double waterLevel,
    String status, {
    String type = 'info',
    String? poolName,
  }) {
    final levelCm = waterLevel.toStringAsFixed(1);
    final message = 'Level air $status (${levelCm}cm)';

    // Create the notification item
    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Level Air',
      message: '$message - ${poolName ?? 'Unknown'}',
      type: type,
      timestamp: DateTime.now(),
      poolName: poolName,
    );

    // Add to in-app notifications
    _notificationProvider.addNotification(notification);

    // Show system notification
    String title = 'Status Level Air';
    String body = poolName != null ? '$message pada $poolName' : message;

    _showNotification(
      title,
      body,
      'system_notifications',
      'System Notifications',
    );
  }

  void sendTestValveNotifications({String? poolName}) {
    addValveNotification(
      true,
      'Test Manual Open',
      type: 'warning',
      poolName: poolName,
    );

    Future.delayed(const Duration(seconds: 1), () {
      addValveNotification(
        false,
        'Test Manual Close',
        type: 'info',
        poolName: poolName,
      );
    });

    Future.delayed(const Duration(seconds: 2), () {
      addValveNotification(
        true,
        'Test Auto Open - Level Rendah',
        type: 'warning',
        poolName: poolName,
      );
    });

    Future.delayed(const Duration(seconds: 3), () {
      addValveNotification(
        false,
        'Test Auto Close - Level Normal',
        type: 'success',
        poolName: poolName,
      );
    });

    Future.delayed(const Duration(seconds: 4), () {
      addValveNotification(
        false,
        'Test Emergency Close',
        type: 'error',
        poolName: poolName,
      );
    });

    addSystemNotification(
      'Test notifikasi valve telah dimulai',
      'info',
      poolName: poolName,
    );
  }

  // Method to handle general notifications from the pool provider
  void addPoolNotification(NotificationItem notification) {
    // Add to in-app notifications first
    _notificationProvider.addNotification(notification);

    // Then show in system notification bar
    String title = notification.title;
    String body = notification.poolName != null
        ? '${notification.message} pada ${notification.poolName}'
        : notification.message;

    // Determine channel based on notification type
    String channelId = 'system_notifications';
    String channelName = 'System Notifications';

    if (notification.message.contains('Kran') ||
        notification.message.contains('kran')) {
      channelId = 'valve_notifications';
      channelName = 'Valve Notifications';
    } else if (notification.message.contains('Pompa') ||
        notification.message.contains('pompa')) {
      channelId = 'pump_notifications';
      channelName = 'Pump Notifications';
    }

    _showNotification(title, body, channelId, channelName);
  }

  // Show a general information notification in the system notification bar
  void showInfoNotification(String title, String message) {
    Logger().i("Showing info notification: $title - $message");

    _showNotification(
      title,
      message,
      'system_notifications',
      'System Notifications',
    );
  }

  String _getTitleByType(String type) {
    switch (type) {
      case 'error':
        return 'Error Sistem';
      case 'warning':
        return 'Peringatan Sistem';
      case 'success':
        return 'Status Normal';
      default:
        return 'Info Sistem';
    }
  }
}
