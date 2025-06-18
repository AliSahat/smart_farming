// lib/screens/dashboard_screen.dart
// ignore_for_file: prefer_final_fields, unused_field, unused_element, unused_import

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_farming/models/esp_water_data.dart';
import 'package:smart_farming/services/repository/esp_repository.dart';
import 'package:smart_farming/utils/logger.dart';
import '../providers/pool_provider.dart';
import '../providers/notification_provider.dart'; // Tambah import ini

import '../models/notification_model.dart';
import '../models/pool_model.dart';
import '../data/pool_data.dart';
import '../screens/add_pool_screen.dart';

import '../widgets/dashboard/header_widget.dart';
import '../widgets/dashboard/water_monitor_widget.dart';
import '../widgets/dashboard/pool_selector_widget.dart';
import '../widgets/dashboard/pool_settings_widget.dart';
import '../widgets/dashboard/control_status_card.dart';
import '../widgets/dashboard/manual_controls_card.dart';
import '../widgets/dashboard/sensor_data_card.dart';

class DashboardScreen extends StatefulWidget {
  final Function(NotificationItem)? onNotificationAdded;

  const DashboardScreen({super.key, this.onNotificationAdded});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // State variables
  double _waterLevel = 65.0;
  String _valveStatus = 'auto';
  String _drainStatus = 'closed';
  bool _isConnected = true;
  bool _showSettings = false;
  String _selectedPoolKey = 'aquarium';
  Timer? _waterLevelTimer;
  bool _isInitialized = false;

  // ESP repository untuk mengambil data
  final ESPRepository _espRepository = ESPRepository();
  ESPWaterData? _latestWaterData;
  bool _isLoading = false;
  Timer? _dataRefreshTimer;

  // Pool settings menggunakan data dari PoolData
  Map<String, Pool> _poolSettings = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      final poolProvider = Provider.of<PoolProvider>(context, listen: false);

      // Load pools from database
      await poolProvider.loadPools();

      // Ambil pools dari provider
      _poolSettings = poolProvider.pools;

      // Set selected pool jika ada
      if (poolProvider.selectedPoolKey.isNotEmpty) {
        _selectedPoolKey = poolProvider.selectedPoolKey;
      }

      setState(() {
        _isInitialized = true;
      });

      if (_poolSettings.isNotEmpty) {
        _fetchWaterData();
        _setupDataRefresh();
        _addNotification('Sistem dimulai', 'success');

        // Start simulation if not already running
        if (!poolProvider.isLoading) {
          poolProvider.startWaterLevelSimulation();
        }
      } else {
        _addNotification(
          'Belum ada pool, silakan tambahkan pool pertama',
          'info',
        );
      }
    } catch (e) {
      debugPrint('Error in _loadInitialData: $e');
      setState(() {
        _isInitialized = true;
      });
      _addNotification('Error saat memuat data: $e', 'error');
    }
  }

  @override
  void dispose() {
    _waterLevelTimer?.cancel();
    _dataRefreshTimer?.cancel();
    super.dispose();
  }

  void _checkWaterLevelAndControl() {
    final currentPool = _poolSettings[_selectedPoolKey]!;
    final currentDepthCm = currentPool.currentDepth;

    // Debug current status
    _debugCurrentStatus();

    Logger.d(
      'Dashboard: Checking water level control - Current depth: $currentDepthCm cm',
    );

    // Konversi persentase ke cm untuk perbandingan yang tepat
    final minDepthCm = (currentPool.minLevel / 100) * currentPool.depth;
    final maxDepthCm = (currentPool.maxLevel / 100) * currentPool.depth;

    Logger.d(
      'Dashboard: Calculated thresholds - Min: $minDepthCm cm, Max: $maxDepthCm cm',
    );

    String previousValveStatus = _valveStatus;
    String previousDrainStatus = _drainStatus;

    if (currentDepthCm < minDepthCm) {
      // Level air terlalu rendah
      setState(() {
        _valveStatus = 'open';
        _drainStatus = 'closed';
      });

      // Tambah notifikasi jika status berubah
      if (previousValveStatus != 'open' || previousDrainStatus != 'closed') {
        _addNotification(
          'Level air rendah (${currentDepthCm.toStringAsFixed(1)} cm)! Kran dibuka otomatis',
          'warning',
        );
      }
      Logger.i('Dashboard: Water level too low, opening valve');
    } else if (currentDepthCm > maxDepthCm) {
      // Level air terlalu tinggi
      setState(() {
        _valveStatus = 'closed';
        _drainStatus = 'open';
      });

      // Tambah notifikasi jika status berubah
      if (previousValveStatus != 'closed' || previousDrainStatus != 'open') {
        _addNotification(
          'Level air berlebihan (${currentDepthCm.toStringAsFixed(1)} cm)! Kran ditutup, pembuangan dibuka',
          'warning',
        );
      }
      Logger.i(
        'Dashboard: Water level too high, closing valve and opening drain',
      );
    } else if (currentDepthCm >= currentPool.normalLevel - 5 &&
        currentDepthCm <= currentPool.normalLevel + 5) {
      // Level air normal
      setState(() {
        _valveStatus = 'auto';
        _drainStatus = 'closed';
      });

      // Tambah notifikasi jika status berubah dari kondisi darurat
      if ((previousValveStatus == 'open' && previousDrainStatus == 'closed') ||
          (previousValveStatus == 'closed' && previousDrainStatus == 'open')) {
        _addNotification(
          'Level air kembali normal (${currentDepthCm.toStringAsFixed(1)} cm)',
          'success',
        );
      }
      Logger.i('Dashboard: Water level normal, setting to auto mode');
    } else if (currentDepthCm < currentPool.normalLevel) {
      // Level air di bawah normal tapi masih di atas minimum
      setState(() {
        _valveStatus = 'open';
        _drainStatus = 'closed';
      });

      if (previousValveStatus != 'open') {
        _addNotification(
          'Level air di bawah normal, kran dibuka untuk pengisian',
          'info',
        );
      }
      Logger.i('Dashboard: Water level below normal, opening valve');
    } else {
      // Level air di atas normal tapi masih di bawah maksimum
      setState(() {
        _valveStatus = 'closed';
        _drainStatus = 'closed';
      });

      if (previousValveStatus == 'open') {
        _addNotification('Level air cukup, kran ditutup', 'info');
      }
      Logger.i(
        'Dashboard: Water level above normal but below max, closing valve',
      );
    }
  }

  void _addNotification(String message, String type) {
    Logger.d('Dashboard: Adding notification - $message ($type)');

    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _getNotificationTitle(type),
      message: message,
      type: type,
      timestamp: DateTime.now(),
      poolName: _poolSettings[_selectedPoolKey]?.name ?? 'Unknown',
    );

    notificationProvider.addNotification(notification);

    Logger.i('Dashboard: Notification added successfully');
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'warning':
        return 'Peringatan Sistem';
      case 'error':
        return 'Error Sistem';
      case 'success':
        return 'Status Normal';
      case 'info':
      default:
        return 'Informasi Sistem';
    }
  }

  void _onPoolSelected(String poolKey) {
    if (!_isInitialized) return;

    setState(() {
      _selectedPoolKey = poolKey;
    });

    _checkWaterLevelAndControl();
    _addNotification('Beralih ke ${_poolSettings[poolKey]?.name}', 'info');
  }

  void _onPoolSettingsChanged(Pool newPool) async {
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    final success = await poolProvider.updatePool(_selectedPoolKey, newPool);

    if (success) {
      _refreshMonitoringData();
      _addNotification('Pengaturan ${newPool.name} diperbarui', 'success');
    } else {
      _addNotification('Gagal memperbarui pengaturan', 'error');
    }
  }

  void _onPoolAdded(String key, Pool pool) async {
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    final success = await poolProvider.addPool(key, pool);

    if (success) {
      setState(() {
        _selectedPoolKey = key;
      });
      _addNotification(
        'Kolam/wadah "${pool.name}" berhasil ditambahkan',
        'success',
      );
    } else {
      _addNotification('Gagal menambahkan kolam/wadah', 'error');
    }
  }

  void _navigateToAddPool() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPoolScreen(onPoolAdded: _onPoolAdded),
      ),
    );
  }

  void _refreshMonitoringData() {
    final currentPool = _poolSettings[_selectedPoolKey]!;

    if (currentPool.currentDepth >= 0) {
      setState(() {
        _waterLevel = (currentPool.currentDepth / currentPool.depth) * 100;
        _waterLevel = _waterLevel.clamp(0.0, 100.0);
      });

      _checkWaterLevelAndControl();
    }
  }

  void _setupDataRefresh() {
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _fetchWaterData();
      }
    });
  }

  Future<void> _fetchWaterData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _espRepository.getLatestWaterDistance();

      if (mounted) {
        setState(() {
          _latestWaterData = data;
          _isLoading = false;

          if (data.isSuccess) {
            final currentPool = _poolSettings[_selectedPoolKey]!;
            final remainingSpace = data.distanceToWater;

            currentPool.currentDepth = currentPool.depth - remainingSpace;
            if (currentPool.currentDepth < 0) currentPool.currentDepth = 0;

            _waterLevel = (currentPool.currentDepth / currentPool.depth) * 100;
            _waterLevel = _waterLevel.clamp(0.0, 100.0);

            _checkWaterLevelAndControl();
          } else {
            _addNotification('Error: ${data.errorMessage}', 'error');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _addNotification('Error fetching data: $e', 'error');
      }
    }
  }

  void _onValveStatusChanged(String status) {
    setState(() {
      _valveStatus = status;
    });

    final message = status == 'open'
        ? 'Kran utama dibuka secara manual'
        : 'Kran utama ditutup secara manual';

    _addNotification(message, 'info');
    Logger.i('Dashboard: Valve status changed manually to $status');
  }

  void _onDrainStatusChanged(String status) {
    setState(() {
      _drainStatus = status;
    });

    final message = status == 'open'
        ? 'Kran pembuangan dibuka secara manual'
        : 'Kran pembuangan ditutup secara manual';

    _addNotification(message, 'info');
    Logger.i('Dashboard: Drain status changed manually to $status');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PoolProvider>(
      builder: (context, poolProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: !_isInitialized
                ? const Center(child: CircularProgressIndicator())
                : _buildDashboard(),
          ),
        );
      },
    );
  }

  Widget _buildDashboard() {
    final currentPool = _poolSettings[_selectedPoolKey];
    if (currentPool == null) {
      return _buildNoPoolState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          HeaderWidget(
            userName: 'Smart Farmer',
            connectionStatus: _isConnected,
          ),
          const SizedBox(height: 20),

          // Pool Selection
          PoolSelectorWidget(
            poolSettings: _poolSettings,
            selectedPoolKey: _selectedPoolKey,
            onPoolSelected: _onPoolSelected,
            onAddPoolTapped: _navigateToAddPool,
          ),
          const SizedBox(height: 20),

          // Water Monitor
          WaterMonitorWidget(
            waterLevel: _waterLevel,
            pool: currentPool,
            latestWaterData: _latestWaterData,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 20),

          // Status Kontrol saja (tanpa Manual Controls)
          ControlStatusCard(
            valveStatus: _valveStatus,
            drainStatus: _drainStatus,
            normalLevel: currentPool.normalLevel,
          ),
          const SizedBox(height: 20),

          // Sensor Data
          SensorDataCard(
            latestWaterData: _latestWaterData,
            onToggleSettings: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
            showSettings: _showSettings,
            waterLevelPercent: _waterLevel,
            poolName: currentPool.name,
          ),
          const SizedBox(height: 20),

          // Settings (jika ditampilkan)
          if (_showSettings) ...[
            PoolSettingsWidget(
              pool: currentPool,
              onSettingsChanged: _onPoolSettingsChanged,
              waterLevelPercent: _waterLevel,
            ),
            const SizedBox(height: 20),
          ],

          // Manual Controls - Dipindah ke paling bawah
          ManualControlsCard(
            valveStatus: _valveStatus,
            drainStatus: _drainStatus,
            onValveStatusChanged: _onValveStatusChanged,
            onDrainStatusChanged: _onDrainStatusChanged,
          ),
          const SizedBox(height: 20), // Tambah spacing di akhir
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cara Menggunakan'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '1. Tambah Kolam/Wadah',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Klik tombol "Tambah Kolam/Wadah" untuk menambahkan kolam atau wadah air pertama Anda.',
              ),
              SizedBox(height: 12),
              Text(
                '2. Atur Parameter',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Masukkan nama, kedalaman, dan batas level air untuk monitoring otomatis.',
              ),
              SizedBox(height: 12),
              Text(
                '3. Mulai Monitoring',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Sistem akan otomatis memantau level air dan mengontrol kran sesuai pengaturan.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _debugCurrentStatus() {
    final currentPool = _poolSettings[_selectedPoolKey]!;
    Logger.d('Dashboard: Debugging current status');
    Logger.d('  Selected pool: ${currentPool.name}');
    Logger.d('  Current depth (cm): ${currentPool.currentDepth}');
    Logger.d('  Normal level (cm): ${currentPool.normalLevel}');
    Logger.d('  Min level (percentage): ${currentPool.minLevel}');
    Logger.d('  Max level (percentage): ${currentPool.maxLevel}');
    Logger.d('  Valve status: $_valveStatus');
    Logger.d('  Drain status: $_drainStatus');
  }

  Widget _buildNoPoolState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.pool, size: 80, color: Colors.blue[400]),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Kolam/Wadah',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tambahkan kolam atau wadah pertama Anda\nuntuk mulai monitoring',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToAddPool,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Tambah Kolam/Wadah'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _showHelpDialog();
            },
            child: const Text('Butuh bantuan?'),
          ),
        ],
      ),
    );
  }
}
