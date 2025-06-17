// lib/main.dart
// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import

import 'theme/app_theme.dart';
import 'providers/pool_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const SmartFarmingApp());
}

class SmartFarmingApp extends StatelessWidget {
  const SmartFarmingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PoolProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Farming',
        theme: lightThemeData,
        home: const MainScreen(),
      ),
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
      final poolProvider = Provider.of<PoolProvider>(context, listen: false);
      poolProvider.startWaterLevelSimulation();
    });
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
