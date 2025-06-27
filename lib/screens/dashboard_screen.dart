// lib/screens/dashboard_screen.dart
// Optimasi dengan Selector dan interval yang lebih panjang
// ignore_for_file: prefer_final_fields, unused_field, unused_element, unused_import, curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_farming/models/esp_water_data.dart';
import 'package:smart_farming/services/repository/esp_repository.dart';
import 'package:smart_farming/utils/logger.dart';
import '../providers/pool_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/app_settings_provider.dart';
import '../models/notification_model.dart';
import '../models/pool_model.dart';
import '../screens/add_pool_screen.dart';
import '../widgets/dashboard/header_widget.dart';
import '../widgets/dashboard/water_monitor_widget.dart';
import '../widgets/dashboard/pool_selector_widget.dart';
import '../widgets/dashboard/pool_settings_widget.dart';
import '../widgets/dashboard/control_status_card.dart';
import '../widgets/dashboard/manual_controls_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showSettings = false;
  ESPWaterData? _latestWaterData;
  Timer? _dataRefreshTimer;
  
  // Add flag to prevent excessive rebuilds
  bool _isDataFetching = false;

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

  // Optimize data fetching to prevent excessive calls
  Future<void> _fetchWaterData() async {
    if (_isDataFetching) return; // Prevent multiple simultaneous calls
    
    _isDataFetching = true;
    
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    final settingsProvider = Provider.of<AppSettingsProvider>(
      context,
      listen: false,
    );
    
    if (!mounted || poolProvider.isEmpty) {
      _isDataFetching = false;
      return;
    }
    
    final espRepository = ESPRepository();
    try {
      final data = await espRepository.getLatestWaterDistance();
      if (mounted) {
        setState(() => _latestWaterData = data);
        if (data.isSuccess) {
          poolProvider.updateCurrentWaterLevel(
            distanceToWater: data.distanceToWater,
            onNotification: _addNotification,
            isSafetyTimerEnabled: settingsProvider.isSafetyTimerEnabled,
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
    } finally {
      _isDataFetching = false;
    }
  }

  // Optimize timer to run less frequently when not needed
  void _setupDataRefresh() {
    _dataRefreshTimer?.cancel();
    // Perlambat refresh dari 30 detik ke 2 menit
    _dataRefreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (mounted && !_isDataFetching) {
        _fetchWaterData();
      }
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

  Future<void> _onPoolAdded(String key, Pool pool) async {
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    if (await poolProvider.addPool(key, pool)) {
      _onPoolSelected(key);
      if (poolProvider.pools.length == 1) _setupDataRefresh();
    }
  }

  Future<void> _onPoolSettingsChanged(Pool newPool) async {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // Ganti Consumer dengan Selector untuk optimization
      body: Selector<PoolProvider, String>(
        selector: (context, provider) => 
          '${provider.isInitialized}_${provider.isEmpty}_${provider.selectedPoolKey}',
        builder: (context, key, child) {
          final poolProvider = Provider.of<PoolProvider>(context, listen: false);
          
          if (!poolProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          if (poolProvider.isEmpty) {
            return _buildNoPoolState();
          }
          return _buildDashboard(poolProvider);
        },
      ),
    );
  }
  
  Widget _buildDashboard(PoolProvider poolProvider) {
    final currentPool = poolProvider.currentPool!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - static, tidak perlu rebuild
          HeaderWidget(
            userName: 'Smart Farmer', 
            connectionStatus: true,
          ),
          
          const SizedBox(height: 20),
          
          // Pool selector - hanya rebuild saat pools berubah
          Selector<PoolProvider, String>(
            selector: (context, provider) => 
              '${provider.pools.length}_${provider.selectedPoolKey}',
            builder: (context, poolsKey, child) {
              return PoolSelectorWidget(
                poolSettings: poolProvider.pools,
                selectedPoolKey: poolProvider.selectedPoolKey,
                onPoolSelected: _onPoolSelected,
                onAddPoolTapped: _navigateToAddPool,
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Water monitor - hanya rebuild saat level berubah signifikan
          Selector<PoolProvider, double>(
            selector: (context, provider) => 
              (provider.currentPool?.currentLevelPercent ?? 0).roundToDouble(),
            builder: (context, waterLevel, child) {
              return WaterMonitorWidget(
                waterLevel: waterLevel,
                pool: currentPool,
                latestWaterData: _latestWaterData,
                isLoading: false, // Remove isLoading dependency
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Control status - hanya rebuild saat status berubah
          Selector<PoolProvider, String>(
            selector: (context, provider) => 
              '${provider.valveStatus.toString()}_${provider.drainStatus.toString()}',
            builder: (context, statusKey, child) {
              return ControlStatusCard(
                valveStatus: poolProvider.valveStatus,
                drainStatus: poolProvider.drainStatus,
                normalLevel: currentPool.normalLevel,
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Manual controls - hanya rebuild saat manual mode berubah
          Selector<PoolProvider, String>(
            selector: (context, provider) => 
              '${provider.isManualMode}_${provider.valveStatus.toString()}_${provider.drainStatus.toString()}',
            builder: (context, controlKey, child) {
              return ManualControlsCard(
                isManualMode: poolProvider.isManualMode,
                valveStatus: poolProvider.valveStatus,
                drainStatus: poolProvider.drainStatus,
                onManualModeChanged: (isActive) {
                  poolProvider.setManualMode(
                    isActive,
                    onNotification: _addNotification,
                  );
                },
                onValveChanged: (status) {
                  poolProvider.manualSetValve(
                    status,
                    onNotification: _addNotification,
                  );
                },
                onDrainChanged: (status) {
                  poolProvider.manualSetDrain(
                    status,
                    onNotification: _addNotification,
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Settings toggle - static
          if (_showSettings) ...[
            PoolSettingsWidget(
              pool: currentPool,
              onSettingsChanged: _onPoolSettingsChanged,
              waterLevelPercent: currentPool.currentLevelPercent,
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
        ],
      ),
    );
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
