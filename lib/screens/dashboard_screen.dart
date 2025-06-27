// lib/screens/dashboard_screen.dart
// VERSI PERBAIKAN FINAL (LAGI) - SEMUA ERROR DIPERBAIKI
// ignore_for_file: prefer_final_fields, unused_field, unused_element, unused_import

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:smart_farming/helper/notification_service.dart';
import 'package:smart_farming/models/esp_water_data.dart';
import 'package:smart_farming/services/repository/esp_repository.dart';
import 'package:smart_farming/utils/logger.dart' hide Logger;
import 'package:smart_farming/widgets/dashboard/manual_controls_card.dart';
import 'package:smart_farming/widgets/dashboard/no_pool_state.dart';
import 'package:smart_farming/widgets/permissions/notification_permission_dialog.dart';
import '../providers/pool_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/app_settings_provider.dart';
import '../models/pool_model.dart';
import '../screens/add_pool_screen.dart';

import '../widgets/dashboard/header_widget.dart';
import '../widgets/dashboard/water_monitor_widget.dart';
import '../widgets/dashboard/pool_selector_widget.dart';
import '../widgets/dashboard/pool_settings_widget.dart';
import '../widgets/dashboard/control_status_card.dart';
import 'package:logger/logger.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showSettings = false;
  ESPWaterData? _latestWaterData;
  Timer? _dataRefreshTimer;
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    Logger().i("🏁 Dashboard screen initializing");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeServices();
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _dataRefreshTimer?.cancel();
    super.dispose();
  }

  void _initializeServices() {
    Logger().i("🔧 Initializing dashboard services");
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    _notificationService = NotificationService(notificationProvider);
    Logger().i("✅ Services initialized successfully");
  }

  Future<void> _loadInitialData() async {
    Logger().i("📊 Loading initial pool data");
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    await poolProvider.loadPools();
    if (mounted && poolProvider.pools.isNotEmpty) {
      Logger().i(
        "🏊 Found ${poolProvider.pools.length} pools, fetching water data",
      );
      _fetchWaterData();
      _setupDataRefresh();
    } else {
      Logger().i("⚠️ No pools found or widget unmounted");
    }
  }

  Future<void> _fetchWaterData() async {
    Logger().d("📡 Fetching water sensor data");
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    final settingsProvider = Provider.of<AppSettingsProvider>(
      context,
      listen: false,
    );

    if (!mounted || poolProvider.isEmpty) {
      Logger().d("❌ Fetch aborted: widget unmounted or no pools");
      return;
    }

    final espRepository = ESPRepository();
    try {
      Logger().d("🔍 Requesting latest water distance data");
      final data = await espRepository.getLatestWaterDistance();
      if (mounted) {
        setState(() => _latestWaterData = data);
        if (data.isSuccess) {
          Logger().i("✅ Water data received: ${data.distanceToWater}cm");
          poolProvider.updateCurrentWaterLevel(
            distanceToWater: data.distanceToWater,
            onNotification: _notificationService.addNotificationFromItem,
            isSafetyTimerEnabled:
                settingsProvider.isSafetyTimerEnabled ?? false,
          );
        } else {
          Logger().e("❌ Sensor error: ${data.errorMessage}");
          _notificationService.addSystemNotification(
            'Sensor offline: ${data.errorMessage}',
            'error',
            poolName: poolProvider.currentPool?.name,
          );
        }
      }
    } catch (e) {
      Logger().e("💥 Exception while fetching water data", error: e);
      if (mounted) {
        _notificationService.addSystemNotification(
          'Error koneksi ke sensor: $e',
          'error',
          poolName: poolProvider.currentPool?.name,
        );
      }
    }
  }

  void _setupDataRefresh() {
    _dataRefreshTimer?.cancel();
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) _fetchWaterData();
    });
  }

  void _onPoolSelected(String poolKey) {
    Provider.of<PoolProvider>(context, listen: false).selectPool(poolKey);
    _fetchWaterData();
    final poolName = Provider.of<PoolProvider>(
      context,
      listen: false,
    ).pools[poolKey]?.name;
    _notificationService.addSystemNotification(
      'Beralih ke "$poolName"',
      'info',
    );
  }

  void _onPoolAdded(String key, Pool pool) async {
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    if (await poolProvider.addPool(key, pool)) {
      _onPoolSelected(key);
      if (poolProvider.pools.length == 1) _setupDataRefresh();
    }
  }

  void _onPoolSettingsChanged(Pool newPool) async {
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    await poolProvider.updatePool(poolProvider.selectedPoolKey, newPool);
    _fetchWaterData();
  }

  void _navigateToAddPool() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddPoolScreen(onPoolAdded: _onPoolAdded),
    ),
  );
  void _testNotifications() async {
    // First check permission status
    final status = await Permission.notification.status;
    debugPrint(
      "Notification permission status: $status",
    ); // See if permission is granted

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notifikasi tidak dapat ditampilkan: Izin tidak diberikan',
          ),
          backgroundColor: Colors.red,
        ),
      );
      // Request permission
      await NotificationPermissionHelper.checkAndRequestPermission(context);
      return;
    }

    // Continue with sending notification...
    _notificationService.addSystemNotification(
      'Ini adalah notifikasi uji coba sistem',
      'info',
      poolName: Provider.of<PoolProvider>(
        context,
        listen: false,
      ).currentPool?.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PoolProvider>(
      builder: (context, poolProvider, child) {
        if (!poolProvider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (poolProvider.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: NoPoolStateWidget(onAddPoolPressed: _navigateToAddPool),
          );
        }

        return _buildDashboard(poolProvider);
      },
    );
  }

  Widget _buildDashboard(PoolProvider poolProvider) {
    final currentPool = poolProvider.currentPool!;
    final waterLevelPercent = currentPool.currentLevelPercent;
    final settingsProvider = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(userName: 'Smart Farmer', connectionStatus: true),
            const SizedBox(height: 20),
            PoolSelectorWidget(
              poolSettings: poolProvider.pools,
              selectedPoolKey: poolProvider.selectedPoolKey,
              onPoolSelected: _onPoolSelected,
              onAddPoolTapped: _navigateToAddPool,
            ),
            const SizedBox(height: 20),
            WaterMonitorWidget(
              waterLevel: waterLevelPercent,
              pool: currentPool,
              latestWaterData: _latestWaterData,
              isLoading: poolProvider.isLoading,
            ),
            const SizedBox(height: 20),
            ControlStatusCard(
              valveStatus: poolProvider.valveStatus,
              drainStatus: poolProvider.drainStatus,
              normalLevel: currentPool.normalLevel,
            ),
            const SizedBox(height: 20),
            if (_showSettings) ...[
              PoolSettingsWidget(
                pool: currentPool,
                onSettingsChanged: _onPoolSettingsChanged,
                waterLevelPercent: waterLevelPercent,
              ),
              const SizedBox(height: 20),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _showSettings = !_showSettings),
                icon: Icon(
                  _showSettings ? Icons.expand_less : Icons.expand_more,
                ),
                label: Text(
                  _showSettings
                      ? 'Sembunyikan Pengaturan'
                      : 'Tampilkan Pengaturan',
                ),
              ),
            ),
            const SizedBox(height: 20),
            ManualControlCard(
              isAutoModeEnabled: settingsProvider.isAutoModeEnabled ?? false,
              poolName: currentPool.name,
            ),
          ],
        ),
      ),
    );
  }
}
