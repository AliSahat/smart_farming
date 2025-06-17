// lib/screens/dashboard_screen.dart
// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_farming/models/esp_water_data.dart';
import 'package:smart_farming/services/repository/esp_repository.dart';
import 'package:smart_farming/utils/logger.dart';

import '../models/notification_model.dart';
import '../models/pool_model.dart';

import '../widgets/dashboard/header_widget.dart';
import '../widgets/dashboard/water_monitor_widget.dart';
import '../widgets/dashboard/pool_selection_widget.dart';
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
  double _waterLevel = 65.0; // Percentage
  String _valveStatus = 'auto'; // open, closed, auto
  String _drainStatus = 'closed'; // open, closed
  bool _isConnected = true;
  bool _showSettings = false;
  String _selectedPoolKey = 'aquarium';
  Timer? _waterLevelTimer;
  bool _isInitialized = false; // Flag untuk mencegah callback saat build

  // Tambahkan ESP repository untuk mengambil data
  final ESPRepository _espRepository = ESPRepository();
  ESPWaterData? _latestWaterData;
  bool _isLoading = false;
  Timer? _dataRefreshTimer;

  final Map<String, Pool> _poolSettings = {
    'kolam-ikan': Pool(
      name: 'Kolam Ikan',
      maxLevel: 85,
      minLevel: 30,
      normalLevel: 75,
      depth: 150,
      currentDepth: 97.5,
    ),
    'aquarium': Pool(
      name: 'Aquarium',
      maxLevel: 80,
      minLevel: 30,
      normalLevel: 80,
      depth: 100,
      currentDepth: 65,
    ),
    'tangki-air': Pool(
      name: 'Tangki Air',
      maxLevel: 90,
      minLevel: 20,
      normalLevel: 75,
      depth: 200,
      currentDepth: 130,
    ),
  };

  @override
  void initState() {
    super.initState();
    // Schedule initial notification setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isInitialized = true;
      // _startWaterLevelSimulation(); // Comment ini untuk menggunakan data real
      _fetchWaterData(); // Fetch data dari ESP
      _setupDataRefresh(); // Setup periodic refresh
      _addNotification('Sistem dimulai', 'success');
    });
  }

  @override
  void dispose() {
    _waterLevelTimer?.cancel();
    _dataRefreshTimer?.cancel();
    super.dispose();
  }

  void _startWaterLevelSimulation() {
    _waterLevelTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // Simulasi perubahan water level
          _waterLevel += (Random().nextDouble() - 0.5) * 2;
          _waterLevel = _waterLevel.clamp(0.0, 100.0);

          // Update current depth based on water level
          final currentPool = _poolSettings[_selectedPoolKey]!;
          currentPool.currentDepth = (_waterLevel / 100) * currentPool.depth;

          // Auto control logic
          if (_valveStatus == 'auto') {
            _checkWaterLevelAndControl();
          }
        });
      }
    });
  }

  void _checkWaterLevelAndControl() {
    final currentPool = _poolSettings[_selectedPoolKey]!;
    final currentDepthCm = currentPool.currentDepth;

    if (currentDepthCm < 30) {
      _valveStatus = 'open';
      _drainStatus = 'closed';
      _addNotification('Level air rendah! Kran dibuka otomatis', 'warning');
    } else if (currentDepthCm > currentPool.normalLevel) {
      _valveStatus = 'closed';
      _drainStatus = 'open';
      _addNotification('Level air tinggi! Pembuangan dibuka', 'warning');
    } else {
      _valveStatus = 'auto';
      _drainStatus = 'closed';
    }
  }

  void _addNotification(String message, String type) {
    // Hanya kirim notification jika sudah initialized dan widget masih mounted
    if (!_isInitialized || !mounted) return;

    final notification = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      message: message,
      type: type,
      time: DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now()),
      isRead: false,
      poolName: _poolSettings[_selectedPoolKey]?.name,
    );

    // Schedule callback setelah frame selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onNotificationAdded != null && mounted) {
        widget.onNotificationAdded!(notification);
      }
    });

    // Show local snackbar di dashboard
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
    setState(() {
      _selectedPoolKey = poolKey;
      // Auto-show settings when switching pools for better UX
      _showSettings = true;
    });
    _addNotification('Beralih ke ${_poolSettings[poolKey]!.name}', 'info');
  }

  void _onPoolSettingsChanged(Pool newPool) {
    setState(() {
      _poolSettings[_selectedPoolKey] = newPool;
    });
    _addNotification('Pengaturan ${newPool.name} diperbarui', 'success');
  }

  void _setupDataRefresh() {
    // Refresh data setiap 10 detik
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
      Logger.d('Dashboard: Fetching water data');
      final data = await _espRepository.getLatestWaterDistance();
      Logger.i('Dashboard: Got water data: $data');

      if (mounted) {
        setState(() {
          _latestWaterData = data;
          _isLoading = false;

          if (data.isSuccess) {
            final currentPool = _poolSettings[_selectedPoolKey]!;

            // Sisa ruang adalah pembacaan sensor (jarak dari sensor ke air)
            final remainingSpace = data.distanceToWater;
            Logger.d(
              'Dashboard: Sensor distance (remaining space): $remainingSpace cm',
            );

            // Ketinggian air saat ini = kedalaman total - sisa ruang
            currentPool.currentDepth = currentPool.depth - remainingSpace;
            Logger.d(
              'Dashboard: Calculated current depth: ${currentPool.currentDepth} cm',
            );

            // Jika ketinggian air negatif (sensor error), set ke 0
            if (currentPool.currentDepth < 0) currentPool.currentDepth = 0;

            // Calculate water level percentage
            _waterLevel = (currentPool.currentDepth / currentPool.depth) * 100;
            _waterLevel = _waterLevel.clamp(0.0, 100.0);
            Logger.d('Dashboard: Water level percentage: $_waterLevel%');

            // Auto control logic
            if (_valveStatus == 'auto') {
              _checkWaterLevelAndControl();
            }
          } else {
            // Jika error, tambahkan notifikasi
            Logger.e('Dashboard: Error fetching data: ${data.errorMessage}');
            _addNotification('Error: ${data.errorMessage}', 'error');
          }
        });
      }
    } catch (e) {
      Logger.e('Dashboard: Exception during fetch: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _addNotification('Error fetching data: $e', 'error');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

              // Pool Selection dan Settings Section
              Column(
                children: [
                  // Pool Selection
                  PoolSelectionWidget(
                    poolSettings: _poolSettings,
                    selectedPoolKey: _selectedPoolKey,
                    onPoolSelected: _onPoolSelected,
                  ),

                  // Pool Settings (langsung di bawah selection)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: _showSettings ? null : 0,
                    child: _showSettings
                        ? Container(
                            margin: const EdgeInsets.only(top: 12),
                            child: PoolSettingsWidget(
                              pool: currentPool,
                              onSettingsChanged: _onPoolSettingsChanged,
                              waterLevelPercent: _waterLevel,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Main Content - Responsive Layout
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 1200) {
                    // Desktop Layout - 2 kolom
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column - Water Monitor
                        Expanded(
                          flex: 3,
                          child: WaterMonitorWidget(
                            waterLevel: _waterLevel,
                            pool: currentPool,
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Right Column - Controls dan Sensor Data
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
                    // Tablet Layout - 2 columns
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column
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

                        // Right Column
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
                    // Mobile Layout - Single column
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
                        ManualControlsCard(addNotification: _addNotification),
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
  }
}
