// lib/main.dart
// ignore_for_file: deprecated_member_use, unused_element, library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farming/utils/logger.dart';

import 'theme/app_theme.dart';
import 'providers/pool_provider.dart';
import 'providers/notification_provider.dart';
import 'models/notification_model.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database/database_helper.dart';
import 'widgets/shared/custom_bottom_navigation_bar.dart'; // Import navbar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Test database connection saat startup
  try {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    Logger.i('✅ Database initialized successfully');
    Logger.i('Database path: ${db.path}');

    // Print path yang lebih jelas
    print('=== DATABASE LOCATION ===');
    print('Full path: ${db.path}');
    print('========================');

    // Get database info
    final info = await dbHelper.getDatabaseInfo();
    Logger.i('Database info: $info');
  } catch (e) {
    Logger.e('❌ Database initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PoolProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const SmartFarmingApp(),
    ),
  );
}

class SmartFarmingApp extends StatelessWidget {
  const SmartFarmingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farming',
      theme: lightThemeData,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Main app setelah onboarding
class SmartFarmingMainApp extends StatefulWidget {
  const SmartFarmingMainApp({super.key});

  @override
  State<SmartFarmingMainApp> createState() => _SmartFarmingMainAppState();
}

class _SmartFarmingMainAppState extends State<SmartFarmingMainApp> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(onNotificationAdded: _onNotificationAdded),
      const NotificationsScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _onNotificationAdded(NotificationItem notification) {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    notificationProvider.addNotification(notification);
    debugPrint('Notification added from dashboard: ${notification.message}');
  }

  Future<void> _initializeApp() async {
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    try {
      // Load pools first
      await poolProvider.loadPools();

      // Hanya add test notifications jika ada pools
      if (poolProvider.pools.isNotEmpty) {
        notificationProvider.addTestNotifications();
      }

      Logger.i('App initialization completed');
    } catch (e) {
      Logger.e('Error during app initialization: $e');
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
