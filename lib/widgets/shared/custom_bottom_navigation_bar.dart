// lib/widgets/shared/custom_bottom_navigation_bar.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../constants/navigation_constants.dart';
import 'notification_badge.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;

        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: NavigationConstants.selectedColor,
            unselectedItemColor: NavigationConstants.unselectedColor,
            backgroundColor: NavigationConstants.backgroundColor,
            elevation: 0,
            selectedFontSize: NavigationConstants.selectedFontSize,
            unselectedFontSize: NavigationConstants.unselectedFontSize,
            items: _buildNavigationItems(unreadCount),
          ),
        );
      },
    );
  }

  List<BottomNavigationBarItem> _buildNavigationItems(int unreadCount) {
    return NavigationConstants.navigationItems.asMap().entries.map((entry) {
      final int index = entry.key;
      final NavigationItem item = entry.value;

      Widget icon = Icon(
        currentIndex == index ? item.activeIcon : item.icon,
        size: NavigationConstants.iconSize,
      );

      // Add badge untuk notifikasi
      if (index == 1 && unreadCount > 0) {
        icon = NotificationBadge(count: unreadCount, child: icon);
      }

      return BottomNavigationBarItem(icon: icon, label: item.label);
    }).toList();
  }
}
