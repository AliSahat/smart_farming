// lib/constants/navigation_constants.dart
import 'package:flutter/material.dart';

/// Navigation constants and configurations for the app
class NavigationConstants {
  NavigationConstants._(); // Private constructor to prevent instantiation

  // ===== NAVIGATION ITEMS =====

  /// Main navigation items for bottom navigation bar
  static const List<NavigationItem> mainNavigationItems = [
    NavigationItem(
      id: 'dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: '/dashboard',
      semanticLabel: 'Halaman Dashboard',
    ),
    NavigationItem(
      id: 'notifications',
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Notifikasi',
      route: '/notifications',
      semanticLabel: 'Halaman Notifikasi',
      showBadge: true,
    ),
    NavigationItem(
      id: 'history',
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      label: 'Histori',
      route: '/history',
      semanticLabel: 'Halaman Histori',
    ),
    NavigationItem(
      id: 'settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Pengaturan',
      route: '/settings',
      semanticLabel: 'Halaman Pengaturan',
    ),
  ];

  // ===== THEME COLORS =====

  /// Light theme colors
  static const NavigationTheme lightTheme = NavigationTheme(
    selectedColor: Color(0xFF2563EB),
    unselectedColor: Color(0xFF6B7280),
    backgroundColor: Colors.white,
    borderColor: Color(0xFFE5E7EB),
    shadowColor: Color(0x1A000000),
    badgeColor: Color(0xFFEF4444),
    badgeTextColor: Colors.white,
  );

  /// Dark theme colors
  static const NavigationTheme darkTheme = NavigationTheme(
    selectedColor: Color(0xFF60A5FA),
    unselectedColor: Color(0xFF9CA3AF),
    backgroundColor: Color(0xFF1F2937),
    borderColor: Color(0xFF374151),
    shadowColor: Color(0x1AFFFFFF),
    badgeColor: Color(0xFFEF4444),
    badgeTextColor: Colors.white,
  );

  // ===== DIMENSIONS =====

  /// Navigation bar dimensions and sizing
  static const NavigationDimensions dimensions = NavigationDimensions(
    height: 80.0,
    iconSize: 24.0,
    activeIconSize: 26.0,
    labelFontSize: 12.0,
    activeLabelFontSize: 12.0,
    elevation: 8.0,
    borderRadius: 20.0,
    horizontalPadding: 16.0,
    verticalPadding: 8.0,
    itemSpacing: 4.0,
    badgeSize: 18.0,
    badgeFontSize: 10.0,
  );

  // ===== ANIMATION SETTINGS =====

  /// Animation configurations
  static const NavigationAnimations animations = NavigationAnimations(
    selectionDuration: Duration(milliseconds: 250),
    selectionCurve: Curves.easeInOutCubic,
    badgePulseDuration: Duration(milliseconds: 1000),
    badgePulseCurve: Curves.elasticOut,
    iconScaleDuration: Duration(milliseconds: 200),
    iconScaleCurve: Curves.bounceOut,
  );

  // ===== ACCESSIBILITY =====

  /// Accessibility settings
  static const NavigationAccessibility accessibility = NavigationAccessibility(
    enableSemanticLabels: true,
    enableHapticFeedback: true,
    minimumTouchTargetSize: 48.0,
    focusHighlightColor: Color(0xFF2563EB),
  );

  // ===== BACKWARD COMPATIBILITY GETTERS =====

  /// Backward compatibility - use lightTheme.selectedColor instead
  static Color get selectedColor => lightTheme.selectedColor;

  /// Backward compatibility - use lightTheme.unselectedColor instead
  static Color get unselectedColor => lightTheme.unselectedColor;

  /// Backward compatibility - use lightTheme.backgroundColor instead
  static Color get backgroundColor => lightTheme.backgroundColor;

  /// Backward compatibility - use lightTheme.badgeColor instead
  static Color get badgeColor => lightTheme.badgeColor;

  /// Backward compatibility - use dimensions.iconSize instead
  static double get iconSize => dimensions.iconSize;

  /// Backward compatibility - use dimensions.labelFontSize instead
  static double get selectedFontSize => dimensions.labelFontSize;

  /// Backward compatibility - use dimensions.labelFontSize instead
  static double get unselectedFontSize => dimensions.labelFontSize;

  /// Backward compatibility - use dimensions.elevation instead
  static double get elevation => dimensions.elevation;

  /// Backward compatibility - use mainNavigationItems instead
  static List<NavigationItem> get navigationItems => mainNavigationItems;
}

/// Represents a single navigation item
class NavigationItem {
  /// Unique identifier for the navigation item
  final String id;

  /// Icon to display when item is not selected
  final IconData icon;

  /// Icon to display when item is selected
  final IconData activeIcon;

  /// Display label for the navigation item
  final String label;

  /// Route path for navigation
  final String route;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// Whether to show a notification badge
  final bool showBadge;

  /// Badge count (null for dot badge)
  final int? badgeCount;

  /// Whether this item is enabled
  final bool enabled;

  const NavigationItem({
    required this.id,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.semanticLabel,
    this.showBadge = false,
    this.badgeCount,
    this.enabled = true,
  });

  /// Create a copy with modified properties
  NavigationItem copyWith({
    String? id,
    IconData? icon,
    IconData? activeIcon,
    String? label,
    String? route,
    String? semanticLabel,
    bool? showBadge,
    int? badgeCount,
    bool? enabled,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      label: label ?? this.label,
      route: route ?? this.route,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      showBadge: showBadge ?? this.showBadge,
      badgeCount: badgeCount ?? this.badgeCount,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NavigationItem(id: $id, label: $label, route: $route)';
}

/// Theme configuration for navigation
class NavigationTheme {
  final Color selectedColor;
  final Color unselectedColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final Color badgeColor;
  final Color badgeTextColor;

  const NavigationTheme({
    required this.selectedColor,
    required this.unselectedColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.shadowColor,
    required this.badgeColor,
    required this.badgeTextColor,
  });
}

/// Dimension configuration for navigation
class NavigationDimensions {
  final double height;
  final double iconSize;
  final double activeIconSize;
  final double labelFontSize;
  final double activeLabelFontSize;
  final double elevation;
  final double borderRadius;
  final double horizontalPadding;
  final double verticalPadding;
  final double itemSpacing;
  final double badgeSize;
  final double badgeFontSize;

  const NavigationDimensions({
    required this.height,
    required this.iconSize,
    required this.activeIconSize,
    required this.labelFontSize,
    required this.activeLabelFontSize,
    required this.elevation,
    required this.borderRadius,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.itemSpacing,
    required this.badgeSize,
    required this.badgeFontSize,
  });
}

/// Animation configuration for navigation
class NavigationAnimations {
  final Duration selectionDuration;
  final Curve selectionCurve;
  final Duration badgePulseDuration;
  final Curve badgePulseCurve;
  final Duration iconScaleDuration;
  final Curve iconScaleCurve;

  const NavigationAnimations({
    required this.selectionDuration,
    required this.selectionCurve,
    required this.badgePulseDuration,
    required this.badgePulseCurve,
    required this.iconScaleDuration,
    required this.iconScaleCurve,
  });
}

/// Accessibility configuration for navigation
class NavigationAccessibility {
  final bool enableSemanticLabels;
  final bool enableHapticFeedback;
  final double minimumTouchTargetSize;
  final Color focusHighlightColor;

  const NavigationAccessibility({
    required this.enableSemanticLabels,
    required this.enableHapticFeedback,
    required this.minimumTouchTargetSize,
    required this.focusHighlightColor,
  });
}

/// Extension methods for NavigationItem list
extension NavigationItemListExtension on List<NavigationItem> {
  /// Find navigation item by ID
  NavigationItem? findById(String id) {
    try {
      return firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find navigation item by route
  NavigationItem? findByRoute(String route) {
    try {
      return firstWhere((item) => item.route == route);
    } catch (e) {
      return null;
    }
  }

  /// Get enabled navigation items only
  List<NavigationItem> get enabledItems =>
      where((item) => item.enabled).toList();

  /// Get items with badges
  List<NavigationItem> get itemsWithBadges =>
      where((item) => item.showBadge).toList();
}
