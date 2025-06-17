// lib/main.dart
// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'models/notification_model.dart';

void main() {
  runApp(const SmartFarmingApp());
}

class SmartFarmingApp extends StatelessWidget {
  const SmartFarmingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming Control',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Shared notifications state
  final List<NotificationItem> _globalNotifications = [];

  // Gunakan WidgetsBinding untuk schedule callback setelah build selesai
  void _addGlobalNotification(NotificationItem notification) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _globalNotifications.insert(0, notification);
          if (_globalNotifications.length > 50) {
            _globalNotifications.removeLast();
          }
        });
      }
    });
  }

  void _updateNotifications(List<NotificationItem> notifications) {
    if (mounted) {
      setState(() {
        _globalNotifications.clear();
        _globalNotifications.addAll(notifications);
      });
    }
  }

  int get _unreadCount {
    return _globalNotifications.where((n) => !n.isRead).length;
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(onNotificationAdded: _addGlobalNotification);
      case 1:
        return NotificationsScreen(
          notifications: _globalNotifications,
          onNotificationsUpdated: _updateNotifications,
        );
      case 2:
        return const HistoryScreen();
      case 3:
        return const SettingsScreen();
      default:
        return DashboardScreen(onNotificationAdded: _addGlobalNotification);
    }
  }

  final List<NavigationItem> _navItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    NavigationItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Notifikasi',
    ),
    NavigationItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      label: 'Histori',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Pengaturan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(onNotificationAdded: _addGlobalNotification),
          NotificationsScreen(
            notifications: _globalNotifications,
            onNotificationsUpdated: _updateNotifications,
          ),
          const HistoryScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (mounted) {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue[600],
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
            items: _navItems.map((item) {
              final isSelected = _navItems.indexOf(item) == _currentIndex;
              final isNotificationTab = _navItems.indexOf(item) == 1;

              return BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue[50]
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 24,
                      ),
                    ),
                    // Badge untuk notifikasi
                    if (isNotificationTab && _unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _unreadCount > 99 ? '99+' : '$_unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: item.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
