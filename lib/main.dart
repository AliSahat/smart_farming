// lib/main.dart
// VERSI PERBAIKAN FINAL - Menghapus kode sisa
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farming/utils/logger.dart';

import 'theme/app_theme.dart';
import 'providers/pool_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/app_settings_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database/database_helper.dart';
import 'widgets/shared/custom_bottom_navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final dbHelper = DatabaseHelper();
    await dbHelper.database;
    Logger.i('✅ Database initialized successfully');
  } catch (e) {
    Logger.e('❌ Database initialization failed: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PoolProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
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

class SmartFarmingMainApp extends StatefulWidget {
  const SmartFarmingMainApp({super.key});

  @override
  State<SmartFarmingMainApp> createState() => _SmartFarmingMainAppState();
}

class _SmartFarmingMainAppState extends State<SmartFarmingMainApp> {
  int _currentIndex = 0;
  
  // FIX: _screens sekarang tidak perlu lagi menerima parameter
  final List<Widget> _screens = [
    const DashboardScreen(),
    const NotificationsScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

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