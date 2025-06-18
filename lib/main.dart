// lib/main.dart
// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farming/utils/logger.dart';

import 'theme/app_theme.dart';
import 'providers/pool_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Test database connection saat startup
  try {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    Logger.i('✅ Database initialized successfully');
    Logger.i('Database path: ${db.path}'); // <-- Ini akan print path database

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
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const NotificationsScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histori'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
