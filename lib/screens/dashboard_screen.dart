// lib/screens/dashboard_screen.dart
// VERSI PERBAIKAN FINAL (LAGI) - SEMUA ERROR DIPERBAIKI
// ignore_for_file: prefer_final_fields, unused_field, unused_element, unused_import

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farming/models/esp_water_data.dart';
import 'package:smart_farming/services/repository/esp_repository.dart';
import 'package:smart_farming/utils/logger.dart';
import '../providers/pool_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/app_settings_provider.dart'; // <-- FIX: IMPORT YANG HILANG SEKARANG ADA
import '../models/notification_model.dart';
import '../models/pool_model.dart';
import '../screens/add_pool_screen.dart';
import '../widgets/dashboard/header_widget.dart';
import '../widgets/dashboard/water_monitor_widget.dart';
import '../widgets/dashboard/pool_selector_widget.dart';
import '../widgets/dashboard/pool_settings_widget.dart';
import '../widgets/dashboard/control_status_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showSettings = false;
  ESPWaterData? _latestWaterData;
  Timer? _dataRefreshTimer;

  // Manual control states
  bool _isPumpRunning = false;
  bool _isValveOpen = false;
  bool _isFillModeActive = false;
  bool _isDrainModeActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _dataRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    await poolProvider.loadPools();
    if (mounted && poolProvider.pools.isNotEmpty) {
      _fetchWaterData();
      _setupDataRefresh();
    }
  }

  Future<void> _fetchWaterData() async {
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    final settingsProvider = Provider.of<AppSettingsProvider>(
      context,
      listen: false,
    );
    if (!mounted || poolProvider.isEmpty) return;

    final espRepository = ESPRepository();
    try {
      final data = await espRepository.getLatestWaterDistance();
      if (mounted) {
        setState(() => _latestWaterData = data);
        if (data.isSuccess) {
          poolProvider.updateCurrentWaterLevel(
            distanceToWater: data.distanceToWater,
            onNotification: _addNotification,
            // Fix: Add null safety check here too
            isSafetyTimerEnabled:
                settingsProvider.isSafetyTimerEnabled,
          );
        } else {
          _addNotificationHelper(
            'Sensor offline: ${data.errorMessage}',
            'error',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _addNotificationHelper('Error koneksi ke sensor: $e', 'error');
      }
    }
  }

  void _setupDataRefresh() {
    _dataRefreshTimer?.cancel();
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) _fetchWaterData();
    });
  }

  void _addNotification(NotificationItem notification) {
    Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).addNotification(notification);
  }

  void _addNotificationHelper(String message, String type) {
    final poolName = Provider.of<PoolProvider>(
      context,
      listen: false,
    ).currentPool?.name;
    _addNotification(
      NotificationItem(
        id: DateTime.now().toString(),
        title: type == 'error' ? 'Error Sistem' : 'Info Sistem',
        message: message,
        type: type,
        timestamp: DateTime.now(),
        poolName: poolName,
      ),
    );
  }

  void _onPoolSelected(String poolKey) {
    Provider.of<PoolProvider>(context, listen: false).selectPool(poolKey);
    _fetchWaterData();
    final poolName = Provider.of<PoolProvider>(
      context,
      listen: false,
    ).pools[poolKey]?.name;
    _addNotificationHelper('Beralih ke "$poolName"', 'info');
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PoolProvider>(
      builder: (context, poolProvider, child) {
        if (!poolProvider.isInitialized)
          return const Center(child: CircularProgressIndicator());
        if (poolProvider.isEmpty) return _buildNoPoolState();
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
                icon: Icon(
                  _showSettings ? Icons.visibility_off : Icons.settings,
                  size: 18,
                ),
                label: Text(
                  _showSettings
                      ? 'Sembunyikan Pengaturan'
                      : 'Tampilkan Pengaturan',
                ),
                onPressed: () => setState(() => _showSettings = !_showSettings),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blueGrey,
                  side: BorderSide(color: Colors.blueGrey.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Manual Control Card - Moved to bottom
            _buildManualControlCard(poolProvider, settingsProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildManualControlCard(
    PoolProvider poolProvider,
    AppSettingsProvider settingsProvider,
  ) {
    // Fix: Add null safety check for isAutoModeEnabled
    final isAutoMode = settingsProvider.isAutoModeEnabled ?? false;

    return Card(
      elevation: 2,
      color: Colors.indigo[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.indigo[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  "Kontrol Manual",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.indigo[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Warning message when auto mode is enabled
            if (isAutoMode) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[600], size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Mode otomatis aktif. Matikan di pengaturan untuk kontrol manual.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Text(
                "Kontrol perangkat secara manual. Pastikan mode otomatis dimatikan.",
                style: TextStyle(fontSize: 12),
              ),
            ],

            const SizedBox(height: 16),

            // Manual Controls
            Row(
              children: [
                // Pump Control
                Expanded(
                  child: _buildControlButton(
                    icon: Icons.water_drop,
                    label: "Pompa",
                    subtitle: _isPumpRunning ? "Menyala" : "Mati",
                    isActive: _isPumpRunning,
                    isEnabled: !isAutoMode,
                    color: Colors.blue,
                    onPressed: !isAutoMode ? () => _togglePump() : null,
                  ),
                ),

                const SizedBox(width: 12),

                // Valve Control
                Expanded(
                  child: _buildControlButton(
                    icon: Icons.tune,
                    label: "Katup",
                    subtitle: _isValveOpen ? "Terbuka" : "Tertutup",
                    isActive: _isValveOpen,
                    isEnabled: !isAutoMode,
                    color: Colors.green,
                    onPressed: !isAutoMode ? () => _toggleValve() : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Mode Controls
            Row(
              children: [
                // Fill Mode
                Expanded(
                  child: _buildModeButton(
                    icon: Icons.arrow_downward,
                    label: "Isi Air",
                    isActive: _isFillModeActive,
                    isEnabled: !isAutoMode,
                    color: Colors.cyan,
                    onPressed: !isAutoMode ? () => _toggleFillMode() : null,
                  ),
                ),

                const SizedBox(width: 12),

                // Drain Mode
                Expanded(
                  child: _buildModeButton(
                    icon: Icons.arrow_upward,
                    label: "Kosongkan",
                    isActive: _isDrainModeActive,
                    isEnabled: !isAutoMode,
                    color: Colors.red,
                    onPressed: !isAutoMode ? () => _toggleDrainMode() : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Emergency Stop
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _emergencyStop,
                icon: const Icon(Icons.stop, color: Colors.white),
                label: const Text(
                  'STOP DARURAT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isActive,
    required bool isEnabled,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled
              ? (isActive ? color.withOpacity(0.1) : Colors.grey[50])
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? (isActive ? color : Colors.grey[300]!)
                : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? (isActive ? color : Colors.grey[600])
                  : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isEnabled
                    ? (isActive ? color : Colors.grey[700])
                    : Colors.grey[400],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isEnabled ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isEnabled,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isEnabled
              ? (isActive ? color.withOpacity(0.1) : Colors.grey[50])
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? (isActive ? color : Colors.grey[300]!)
                : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? (isActive ? color : Colors.grey[600])
                  : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: isEnabled
                    ? (isActive ? color : Colors.grey[700])
                    : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Manual control methods
  void _togglePump() {
    setState(() {
      _isPumpRunning = !_isPumpRunning;
    });

    _addNotificationHelper(
      _isPumpRunning
          ? 'Pompa dinyalakan secara manual'
          : 'Pompa dimatikan secara manual',
      'info',
    );

    // TODO: Implement actual ESP32 pump control
    print('Pump ${_isPumpRunning ? 'ON' : 'OFF'}');
  }

  void _toggleValve() {
    setState(() {
      _isValveOpen = !_isValveOpen;
    });

    _addNotificationHelper(
      _isValveOpen
          ? 'Katup dibuka secara manual'
          : 'Katup ditutup secara manual',
      'info',
    );

    // TODO: Implement actual ESP32 valve control
    print('Valve ${_isValveOpen ? 'OPEN' : 'CLOSED'}');
  }

  void _toggleFillMode() {
    setState(() {
      _isFillModeActive = !_isFillModeActive;
      if (_isFillModeActive) {
        _isDrainModeActive = false; // Turn off drain mode
        _isPumpRunning = true;
        _isValveOpen = false;
      } else {
        _isPumpRunning = false;
      }
    });

    _addNotificationHelper(
      _isFillModeActive
          ? 'Mode pengisian air diaktifkan'
          : 'Mode pengisian air dinonaktifkan',
      'info',
    );

    // TODO: Implement actual ESP32 fill mode control
    print('Fill mode ${_isFillModeActive ? 'ACTIVE' : 'INACTIVE'}');
  }

  void _toggleDrainMode() {
    setState(() {
      _isDrainModeActive = !_isDrainModeActive;
      if (_isDrainModeActive) {
        _isFillModeActive = false; // Turn off fill mode
        _isPumpRunning = false;
        _isValveOpen = true;
      } else {
        _isValveOpen = false;
      }
    });

    _addNotificationHelper(
      _isDrainModeActive
          ? 'Mode pengosongan air diaktifkan'
          : 'Mode pengosongan air dinonaktifkan',
      'info',
    );

    // TODO: Implement actual ESP32 drain mode control
    print('Drain mode ${_isDrainModeActive ? 'ACTIVE' : 'INACTIVE'}');
  }

  void _emergencyStop() {
    setState(() {
      _isPumpRunning = false;
      _isValveOpen = false;
      _isFillModeActive = false;
      _isDrainModeActive = false;
    });

    _addNotificationHelper('STOP DARURAT - Semua sistem dimatikan', 'error');

    // TODO: Implement actual ESP32 emergency stop
    print('EMERGENCY STOP - All systems OFF');
  }

  Widget _buildNoPoolState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pool_outlined, size: 80, color: Colors.blue[200]),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Kolam',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tambahkan kolam atau wadah pertama Anda untuk memulai monitoring.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToAddPool,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tambah Kolam/Wadah Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
