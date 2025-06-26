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
  final bool showElevation;
  final double? height;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.showElevation = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        final unreadCount = notificationProvider.unreadCount;

        return Container(
          height: height,
          decoration: showElevation ? _buildShadowDecoration(colorScheme) : null,
          child: Material(
            elevation: showElevation ? 8.0 : 0.0,
            shadowColor: colorScheme.shadow.withOpacity(0.1),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: _getSelectedColor(colorScheme),
              unselectedItemColor: _getUnselectedColor(colorScheme),
              backgroundColor: _getBackgroundColor(colorScheme),
              elevation: 0, // Handled by Container decoration
              selectedFontSize: NavigationConstants.selectedFontSize,
              unselectedFontSize: NavigationConstants.selectedFontSize,
              selectedLabelStyle: _getSelectedLabelStyle(theme),
              unselectedLabelStyle: _getUnselectedLabelStyle(theme),
              items: _buildNavigationItems(unreadCount, colorScheme),
              enableFeedback: true,
              mouseCursor: MaterialStateMouseCursor.clickable,
            ),
          ),
        );
      },
    );
  }

  /// Builds shadow decoration for the navigation bar
  BoxDecoration _buildShadowDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, -4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: colorScheme.shadow.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, -2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  /// Gets selected item color based on theme
  Color _getSelectedColor(ColorScheme colorScheme) {
    return NavigationConstants.selectedColor;
  }

  /// Gets unselected item color based on theme
  Color _getUnselectedColor(ColorScheme colorScheme) {
    return NavigationConstants.unselectedColor;
  }

  /// Gets background color based on theme
  Color _getBackgroundColor(ColorScheme colorScheme) {
    return NavigationConstants.backgroundColor;
  }

  /// Gets selected label style
  TextStyle _getSelectedLabelStyle(ThemeData theme) {
    return theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ) ?? const TextStyle(fontWeight: FontWeight.w600);
  }

  /// Gets unselected label style
  TextStyle _getUnselectedLabelStyle(ThemeData theme) {
    return theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w400,
      letterSpacing: 0.3,
    ) ?? const TextStyle(fontWeight: FontWeight.w400);
  }

  /// Builds navigation items with enhanced styling
  List<BottomNavigationBarItem> _buildNavigationItems(
    int unreadCount, 
    ColorScheme colorScheme,
  ) {
    return NavigationConstants.navigationItems.asMap().entries.map((entry) {
      final int index = entry.key;
      final NavigationItem item = entry.value;

      Widget icon = _buildIcon(item, index, colorScheme);

      // Add notification badge if needed
      if (_shouldShowBadge(index, unreadCount)) {
        icon = NotificationBadge(
          count: unreadCount,
          child: icon,
        );
      }

      return BottomNavigationBarItem(
        icon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: icon,
        ),
        activeIcon: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _buildActiveIcon(item, index, colorScheme, unreadCount),
        ),
        label: item.label,
        tooltip: item.tooltip ?? item.label,
      );
    }).toList();
  }

  /// Builds regular icon
  Widget _buildIcon(NavigationItem item, int index, ColorScheme colorScheme) {
    return Icon(
      item.icon,
      size: NavigationConstants.iconSize,
      color: currentIndex == index 
        ? _getSelectedColor(colorScheme)
        : _getUnselectedColor(colorScheme),
    );
  }

  /// Builds active icon with animation
  Widget _buildActiveIcon(
    NavigationItem item, 
    int index, 
    ColorScheme colorScheme, 
    int unreadCount,
  ) {
    Widget activeIcon = Icon(
      item.activeIcon,
      size: NavigationConstants.iconSize,
      color: _getSelectedColor(colorScheme),
    );

    // Add badge for active state if needed
    if (_shouldShowBadge(index, unreadCount)) {
      activeIcon = NotificationBadge(
        count: unreadCount,
        child: activeIcon,
      );
    }

    return activeIcon;
  }

  /// Determines if notification badge should be shown
  bool _shouldShowBadge(int index, int unreadCount) {
    return index == 1 && unreadCount > 0; // Assuming index 1 is notifications
  }
}

/// Extension to add navigation item properties
extension NavigationItemExtension on NavigationItem {
  String? get tooltip => null; // Can be overridden in NavigationItem class
}