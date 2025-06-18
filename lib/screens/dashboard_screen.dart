// lib/screens/dashboard_screen.dart
// ignore_for_file: prefer_final_fields, unused_field, unused_element

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_farming/models/esp_water_data.dart';
import 'package:smart_farming/services/repository/esp_repository.dart';
import 'package:smart_farming/utils/logger.dart';
import '../providers/pool_provider.dart';

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

    Logger.d(
      'Dashboard: Checking water level control - Current depth: $currentDepthCm cm',
    );

    final minDepthCm = (currentPool.minLevel / 100) * currentPool.depth;
    final maxDepthCm = (currentPool.maxLevel / 100) * currentPool.depth;

    if (minDepthCm >= maxDepthCm) {
      Logger.w('Dashboard: Invalid threshold values - min >= max');
      _addNotification('Pengaturan threshold tidak valid', 'warning');
      return;
    }

    if (currentDepthCm < minDepthCm) {
      setState(() {
        _valveStatus = 'open';
        _drainStatus = 'closed';
      });
      _addNotification(
        'Level air rendah (${currentDepthCm.toStringAsFixed(1)} cm)! Kran dibuka otomatis',
        'warning',
      );
    } else if (currentDepthCm > maxDepthCm) {
      setState(() {
        _valveStatus = 'closed';
        _drainStatus = 'open';
      });
      _addNotification(
        'Level air berlebihan (${currentDepthCm.toStringAsFixed(1)} cm)! Kran ditutup dan pembuangan dibuka',
        'warning',
      );
    } else if (currentDepthCm >= currentPool.normalLevel - 5 &&
        currentDepthCm <= currentPool.normalLevel + 5) {
      setState(() {
        _valveStatus = 'auto';
        _drainStatus = 'closed';
      });
    }
  }

  void _addNotification(String message, String type) {
    if (!_isInitialized || !mounted) return;

    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      message: message,
      type: type,
      time: DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now()),
      isRead: false,
      poolName: _poolSettings[_selectedPoolKey]?.name,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onNotificationAdded != null && mounted) {
        widget.onNotificationAdded!(notification);
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(_getNotificationIcon(type), color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: _getNotificationColor(type),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'info':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    return Consumer<PoolProvider>(
      builder: (context, poolProvider, child) {
        // Update local state from provider
        if (poolProvider.isInitialized) {
          _poolSettings = poolProvider.pools;

          // Pastikan selected pool valid
          if (!_poolSettings.containsKey(_selectedPoolKey) &&
              _poolSettings.isNotEmpty) {
            _selectedPoolKey = _poolSettings.keys.first;
          }
        }

        // Jika belum initialized, tampilkan loading
        if (!poolProvider.isInitialized) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat aplikasi...'),
                ],
              ),
            ),
          );
        }

        // Jika tidak ada pool sama sekali, tampilkan empty state
        if (_poolSettings.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    HeaderWidget(
                      isConnected: _isConnected,
                      onSettingsTap: () {},
                    ),
                    const SizedBox(height: 40),

                    // Empty State
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.pool,
                              size: 80,
                              color: Colors.blue[400],
                            ),
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
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _navigateToAddPool,
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Tambah Kolam/Wadah'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
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
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Normal dashboard dengan pools
        final currentPool = _poolSettings[_selectedPoolKey]!;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  HeaderWidget(
                    isConnected: _isConnected,
                    onSettingsTap: () {
                      setState(() {
                        _showSettings = !_showSettings;
                      });
                    },
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

                  // Pool Settings (show/hide)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _showSettings ? null : 0,
                    child: _showSettings
                        ? PoolSettingsWidget(
                            pool: currentPool,
                            onSettingsChanged: _onPoolSettingsChanged,
                            waterLevelPercent: _waterLevel,
                          )
                        : const SizedBox.shrink(),
                  ),
                  if (_showSettings) const SizedBox(height: 20),

                  // Main Content - Responsive Layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 1200) {
                        // Desktop Layout
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: WaterMonitorWidget(
                                waterLevel: _waterLevel,
                                pool: currentPool,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  SensorDataCard(
                                    waterLevel: _waterLevel,
                                    isConnected: _isConnected,
                                    poolName: currentPool.name,
                                  ),
                                  const SizedBox(height: 20),
                                  ControlStatusCard(
                                    valveStatus: _valveStatus,
                                    drainStatus: _drainStatus,
                                    normalLevel: currentPool.normalLevel,
                                  ),
                                  const SizedBox(height: 20),
                                  ManualControlsCard(
                                    addNotification: _addNotification,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else if (constraints.maxWidth > 768) {
                        // Tablet Layout
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  WaterMonitorWidget(
                                    waterLevel: _waterLevel,
                                    pool: currentPool,
                                  ),
                                  const SizedBox(height: 20),
                                  ControlStatusCard(
                                    valveStatus: _valveStatus,
                                    drainStatus: _drainStatus,
                                    normalLevel: currentPool.normalLevel,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  SensorDataCard(
                                    waterLevel: _waterLevel,
                                    isConnected: _isConnected,
                                    poolName: currentPool.name,
                                  ),
                                  const SizedBox(height: 20),
                                  ManualControlsCard(
                                    addNotification: _addNotification,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Mobile Layout
                        return Column(
                          children: [
                            WaterMonitorWidget(
                              waterLevel: _waterLevel,
                              pool: currentPool,
                            ),
                            const SizedBox(height: 20),
                            SensorDataCard(
                              waterLevel: _waterLevel,
                              isConnected: _isConnected,
                              poolName: currentPool.name,
                            ),
                            const SizedBox(height: 20),
                            ControlStatusCard(
                              valveStatus: _valveStatus,
                              drainStatus: _drainStatus,
                              normalLevel: currentPool.normalLevel,
                            ),
                            const SizedBox(height: 20),
                            ManualControlsCard(
                              addNotification: _addNotification,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  // ...existing methods...
}
