// lib/constants/navigation_constants.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Central configuration for app navigation
///
/// This class provides a centralized way to manage navigation items,
/// themes, animations, and accessibility settings.
sealed class NavigationConstants {
  // Prevent instantiation
  NavigationConstants._internal();

  // ===== STATIC CONFIGURATION =====

  /// Current navigation configuration version
  static const String configVersion = '2.0.0';

  /// Maximum number of navigation items allowed
  static const int maxNavigationItems = 5;

  // ===== MAIN NAVIGATION ITEMS =====

  /// Primary navigation items for bottom navigation bar
  static const List<NavigationItem> mainNavigationItems = [
    NavigationItem._internal(
      id: NavigationItemId.dashboard,
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: NavigationRoute.dashboard,
      semanticLabel: 'Halaman Dashboard Utama',
      priority: NavigationPriority.high,
    ),
    NavigationItem._internal(
      id: NavigationItemId.notifications,
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Notifikasi',
      route: NavigationRoute.notifications,
      semanticLabel: 'Halaman Pemberitahuan dan Peringatan',
      showBadge: true,
      priority: NavigationPriority.high,
    ),
    NavigationItem._internal(
      id: NavigationItemId.history,
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      label: 'Histori',
      route: NavigationRoute.history,
      semanticLabel: 'Halaman Riwayat Data',
      priority: NavigationPriority.medium,
    ),
    NavigationItem._internal(
      id: NavigationItemId.settings,
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Pengaturan',
      route: NavigationRoute.settings,
      semanticLabel: 'Halaman Pengaturan Aplikasi',
      priority: NavigationPriority.low,
    ),
  ];

  // ===== THEME CONFIGURATIONS =====

  /// Light theme navigation colors
  static const NavigationTheme lightTheme = NavigationTheme(
    selectedColor: Color(0xFF2563EB),
    unselectedColor: Color(0xFF6B7280),
    backgroundColor: Colors.white,
    borderColor: Color(0xFFE5E7EB),
    shadowColor: Color(0x1A000000),
    badgeColor: Color(0xFFEF4444),
    badgeTextColor: Colors.white,
  );

  /// Dark theme navigation colors
  static const NavigationTheme darkTheme = NavigationTheme(
    selectedColor: Color(0xFF60A5FA),
    unselectedColor: Color(0xFF9CA3AF),
    backgroundColor: Color(0xFF1F2937),
    borderColor: Color(0xFF374151),
    shadowColor: Color(0x40000000),
    badgeColor: Color(0xFFF87171),
    badgeTextColor: Colors.white,
  );

  // ===== DIMENSIONS & SPACING =====

  /// Navigation dimensions configuration
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

  // ===== ANIMATION CONFIGURATIONS =====

  /// Animation settings for navigation interactions
  static const NavigationAnimations animations = NavigationAnimations(
    selectionDuration: Duration(milliseconds: 250),
    selectionCurve: Curves.easeInOutCubic,
    badgePulseDuration: Duration(milliseconds: 1000),
    badgePulseCurve: Curves.elasticOut,
    iconScaleDuration: Duration(milliseconds: 200),
    iconScaleCurve: Curves.bounceOut,
  );

  // ===== ACCESSIBILITY SETTINGS =====

  /// Accessibility configuration
  static const NavigationAccessibility accessibility = NavigationAccessibility(
    enableSemanticLabels: true,
    enableHapticFeedback: true,
    minimumTouchTargetSize: 48.0,
    focusHighlightColor: Color(0xFF2563EB),
  );

  // ===== BACKWARD COMPATIBILITY =====

  /// Legacy getter for navigation items
  @Deprecated('Use NavigationConstants.mainNavigationItems instead')
  static List<NavigationItem> get navigationItems => mainNavigationItems;

  /// Legacy getters for simple access
  static Color get selectedColor => lightTheme.selectedColor;
  static Color get unselectedColor => lightTheme.unselectedColor;
  static Color get backgroundColor => lightTheme.backgroundColor;
  static double get selectedFontSize => dimensions.labelFontSize;
  static double get iconSize => dimensions.iconSize;

  // ===== UTILITY METHODS =====

  /// Get navigation item by ID
  static NavigationItem? getItemById(NavigationItemId id) {
    try {
      return mainNavigationItems.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get navigation item by route
  static NavigationItem? getItemByRoute(String route) {
    try {
      return mainNavigationItems.firstWhere((item) => item.route == route);
    } catch (e) {
      return null;
    }
  }

  /// Get enabled navigation items
  static List<NavigationItem> get enabledItems =>
      mainNavigationItems.where((item) => item.enabled).toList();

  /// Get items with badges
  static List<NavigationItem> get badgedItems =>
      mainNavigationItems.where((item) => item.showBadge).toList();

  /// Validate navigation configuration
  static bool validateConfiguration() {
    // Check item count
    if (mainNavigationItems.length > maxNavigationItems) return false;

    // Check for duplicate IDs
    final ids = mainNavigationItems.map((item) => item.id).toSet();
    if (ids.length != mainNavigationItems.length) return false;

    // Check for duplicate routes
    final routes = mainNavigationItems.map((item) => item.route).toSet();
    if (routes.length != mainNavigationItems.length) return false;

    return true;
  }
}

// ===== ENUMS & TYPE DEFINITIONS =====

/// Strongly typed navigation item identifiers
enum NavigationItemId {
  dashboard('dashboard'),
  notifications('notifications'),
  history('history'),
  settings('settings');

  const NavigationItemId(this.value);
  final String value;

  @override
  String toString() => value;
}

/// Navigation route constants
sealed class NavigationRoute {
  static const String dashboard = '/dashboard';
  static const String notifications = '/notifications';
  static const String history = '/history';
  static const String settings = '/settings';

  /// All valid routes
  static const List<String> all = [dashboard, notifications, history, settings];

  /// Check if route is valid
  static bool isValid(String route) => all.contains(route);
}

/// Navigation item priority levels
enum NavigationPriority {
  low(0),
  medium(1),
  high(2),
  critical(3);

  const NavigationPriority(this.level);
  final int level;

  bool operator >(NavigationPriority other) => level > other.level;
  bool operator <(NavigationPriority other) => level < other.level;
  bool operator >=(NavigationPriority other) => level >= other.level;
  bool operator <=(NavigationPriority other) => level <= other.level;
}

/// Haptic feedback types
enum HapticFeedbackType { selection, impact, heavy, medium, light }

// ===== DATA CLASSES =====

/// Immutable navigation item configuration
@immutable
final class NavigationItem {
  final NavigationItemId id;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String? semanticLabel;
  final bool showBadge;
  final int? badgeCount;
  final bool enabled;
  final NavigationPriority priority;
  final Color? customColor;
  final Map<String, dynamic>? metadata;

  const NavigationItem._internal({
    required this.id,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    this.semanticLabel,
    this.showBadge = false,
    this.badgeCount,
    this.enabled = true,
    this.priority = NavigationPriority.medium,
    this.customColor,
    this.metadata,
  });

  /// Public constructor with validation
  factory NavigationItem({
    required NavigationItemId id,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    String? semanticLabel,
    bool showBadge = false,
    int? badgeCount,
    bool enabled = true,
    NavigationPriority priority = NavigationPriority.medium,
    Color? customColor,
    Map<String, dynamic>? metadata,
  }) {
    // Validation
    assert(label.isNotEmpty, 'Label cannot be empty');
    assert(NavigationRoute.isValid(route), 'Invalid route: $route');
    assert(
      badgeCount == null || badgeCount >= 0,
      'Badge count must be non-negative',
    );

    return NavigationItem._internal(
      id: id,
      icon: icon,
      activeIcon: activeIcon,
      label: label,
      route: route,
      semanticLabel: semanticLabel ?? label,
      showBadge: showBadge,
      badgeCount: badgeCount,
      enabled: enabled,
      priority: priority,
      customColor: customColor,
      metadata: metadata,
    );
  }

  /// Create a copy with modified properties
  NavigationItem copyWith({
    NavigationItemId? id,
    IconData? icon,
    IconData? activeIcon,
    String? label,
    String? route,
    String? semanticLabel,
    bool? showBadge,
    int? badgeCount,
    bool? enabled,
    NavigationPriority? priority,
    Color? customColor,
    Map<String, dynamic>? metadata,
  }) {
    return NavigationItem._internal(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      label: label ?? this.label,
      route: route ?? this.route,
      semanticLabel: semanticLabel ?? this.semanticLabel,
      showBadge: showBadge ?? this.showBadge,
      badgeCount: badgeCount ?? this.badgeCount,
      enabled: enabled ?? this.enabled,
      priority: priority ?? this.priority,
      customColor: customColor ?? this.customColor,
      metadata: metadata ?? this.metadata,
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

/// Navigation theme configuration
@immutable
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

/// Navigation dimensions configuration
@immutable
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

/// Navigation animations configuration
@immutable
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

/// Navigation accessibility configuration
@immutable
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

  /// Execute haptic feedback based on type
  Future<void> performHapticFeedback(HapticFeedbackType type) async {
    if (!enableHapticFeedback) return;

    switch (type) {
      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.impact:
        await HapticFeedback.lightImpact();
        break;
    }
  }
}

// ===== THEME MANAGER =====

/// Get current navigation theme based on context
class NavigationThemeManager {
  static NavigationTheme getTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? NavigationConstants.darkTheme
        : NavigationConstants.lightTheme;
  }

  static NavigationTheme getCurrentTheme(bool isDarkMode) {
    return isDarkMode
        ? NavigationConstants.darkTheme
        : NavigationConstants.lightTheme;
  }
}

// ===== EXTENSIONS =====

/// Extensions for NavigationItem lists
extension NavigationItemListX on List<NavigationItem> {
  /// Find item by ID
  NavigationItem? byId(NavigationItemId id) {
    try {
      return firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find item by route
  NavigationItem? byRoute(String route) {
    try {
      return firstWhere((item) => item.route == route);
    } catch (e) {
      return null;
    }
  }

  /// Get only enabled items
  List<NavigationItem> get enabled => where((item) => item.enabled).toList();

  /// Get items with badges
  List<NavigationItem> get withBadges =>
      where((item) => item.showBadge).toList();

  /// Sort by priority (high to low)
  List<NavigationItem> get sortedByPriority {
    final sorted = List<NavigationItem>.from(this);
    sorted.sort((a, b) => b.priority.level.compareTo(a.priority.level));
    return sorted;
  }

  /// Get total badge count
  int get totalBadgeCount {
    return where(
      (item) => item.showBadge && item.badgeCount != null,
    ).fold<int>(0, (sum, item) => sum + (item.badgeCount ?? 0));
  }
}

/// Extensions for BuildContext navigation
extension NavigationContextX on BuildContext {
  /// Get current theme colors for navigation
  NavigationTheme get navigationTheme {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark
        ? NavigationConstants.darkTheme
        : NavigationConstants.lightTheme;
  }

  /// Get responsive navigation dimensions
  NavigationDimensions get navigationDimensions {
    return NavigationConstants.dimensions;
  }

  /// Check if reduced motion is enabled
  bool get isReducedMotionEnabled {
    return MediaQuery.of(this).disableAnimations;
  }

  /// Check if high contrast is enabled
  bool get isHighContrastEnabled {
    return MediaQuery.of(this).highContrast;
  }
}
