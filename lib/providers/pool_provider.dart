// lib/providers/pool_provider.dart
// VERSI PERBAIKAN FINAL - FIX DEFINISI FUNGSI
// ignore_for_file: unused_import, prefer_final_fields

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_farming/utils/logger.dart';
import '../models/pool_model.dart';
import '../services/database/database_helper.dart';
import '../models/notification_model.dart';

class PoolProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Map<String, Pool> _pools = {};
  String _selectedPoolKey = '';
  ValveStatus _valveStatus = ValveStatus.closed;
  DrainStatus _drainStatus = DrainStatus.closed;
  bool _isLoading = false;
  bool _isInitialized = false;

  Timer? _safetyTimer;
  final Duration _maxDuration = const Duration(minutes: 15);

  Map<String, Pool> get pools => _pools;
  String get selectedPoolKey => _selectedPoolKey;
  Pool? get currentPool => _pools[_selectedPoolKey];
  ValveStatus get valveStatus => _valveStatus;
  DrainStatus get drainStatus => _drainStatus;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get hasValidSelection =>
      _selectedPoolKey.isNotEmpty && _pools.containsKey(_selectedPoolKey);
  bool get isEmpty => _pools.isEmpty;

  Future<void> loadPools() async {
    _isLoading = true;
    notifyListeners();
    try {
      _pools = await _dbHelper.getAllPools();
      if (_pools.isNotEmpty) {
        if (_selectedPoolKey.isEmpty || !_pools.containsKey(_selectedPoolKey)) {
          _selectedPoolKey = _pools.keys.first;
        }
      } else {
        _selectedPoolKey = '';
      }
      _isInitialized = true;
    } catch (e) {
      Logger.e('Error loading pools: $e');
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void checkWaterLevelAndControl({
    required Function(NotificationItem) onNotification,
    required bool isSafetyTimerEnabled,
  }) {
    if (!hasValidSelection) return;
    final pool = currentPool!;
    ValveStatus previousValveStatus = _valveStatus;
    DrainStatus previousDrainStatus = _drainStatus;

    if (pool.isLevelTooLow) {
      _valveStatus = ValveStatus.open;
      _drainStatus = DrainStatus.closed;
    } else if (pool.isLevelTooHigh) {
      _valveStatus = ValveStatus.closed;
      _drainStatus = DrainStatus.open;
    } else {
      _valveStatus = ValveStatus.closed;
      _drainStatus = DrainStatus.closed;
    }

    _safetyTimer?.cancel();
    if (isSafetyTimerEnabled && (_valveStatus == ValveStatus.open || _drainStatus == DrainStatus.open)) {
      _safetyTimer = Timer(_maxDuration, () {
        onNotification(_createNotification('Aksi berjalan terlalu lama! Sistem dihentikan demi keamanan.', 'error'));
        _valveStatus = ValveStatus.closed;
        _drainStatus = DrainStatus.closed;
        notifyListeners();
        Logger.e("SAFETY TIMEOUT: All valves closed.");
      });
    }

    if ((_valveStatus != previousValveStatus || _drainStatus != previousDrainStatus)) {
      final depthCm = pool.currentDepth.toStringAsFixed(1);
      if (_valveStatus == ValveStatus.open) {
        onNotification(_createNotification('Level air rendah (${depthCm}cm). Kran dibuka.', 'warning'));
      } else if (_drainStatus == DrainStatus.open) {
         onNotification(_createNotification('Level air tinggi (${depthCm}cm). Pembuangan dibuka.', 'warning'));
      } else if (previousValveStatus == ValveStatus.open || previousDrainStatus == DrainStatus.open) {
         onNotification(_createNotification('Level air normal (${depthCm}cm). Sistem standby.', 'success'));
      }
    }
    notifyListeners();
  }

  void updateCurrentWaterLevel({
    required double distanceToWater,
    required Function(NotificationItem) onNotification,
    required bool isSafetyTimerEnabled,
  }) {
    if (hasValidSelection) {
      final pool = currentPool!;
      pool.currentDepth = (pool.depth - distanceToWater).clamp(0.0, pool.depth);
      checkWaterLevelAndControl(
        onNotification: onNotification,
        isSafetyTimerEnabled: isSafetyTimerEnabled,
      );
      notifyListeners();
    }
  }

  void simulateWaterLevelChange({
    required double changeInCm,
    required Function(NotificationItem) onNotification,
    required bool isSafetyTimerEnabled,
  }) {
    if (hasValidSelection) {
      final pool = currentPool!;
      pool.currentDepth = (pool.currentDepth + changeInCm).clamp(0.0, pool.depth);
      checkWaterLevelAndControl(
        onNotification: onNotification,
        isSafetyTimerEnabled: isSafetyTimerEnabled,
      );
      Logger.d("Simulated water level: ${pool.currentDepth} cm");
      notifyListeners();
    }
  }

  Future<bool> addPool(String key, Pool pool) async {
    try {
      if (_pools.containsKey(key)) return false;
      await _dbHelper.insertPool(key, pool);
      _pools[key] = pool;
      if (_pools.length == 1) selectPool(key);
      notifyListeners();
      return true;
    } catch(e) { return false; }
  }

  Future<bool> updatePool(String key, Pool pool) async {
    try {
      if (!_pools.containsKey(key)) return false;
      await _dbHelper.updatePool(key, pool);
      _pools[key] = pool;
      notifyListeners();
      return true;
    } catch(e) { return false; }
  }

  Future<bool> deletePool(String key) async {
     try {
      if (!_pools.containsKey(key)) return false;
      await _dbHelper.deletePool(key);
      _pools.remove(key);
      if (_selectedPoolKey == key) {
        _selectedPoolKey = _pools.isNotEmpty ? _pools.keys.first : '';
      }
      notifyListeners();
      return true;
    } catch (e) { return false; }
  }

  void selectPool(String key) {
    if (_pools.containsKey(key)) {
      _selectedPoolKey = key;
      // Panggil checkWaterLevelAndControl tanpa notifikasi saat hanya ganti kolam
      checkWaterLevelAndControl(onNotification: (_) {}, isSafetyTimerEnabled: false);
      notifyListeners();
    }
  }

  NotificationItem _createNotification(String message, String type) {
    return NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: type == 'warning' ? 'Peringatan Level Air' : (type == 'success' ? 'Status Normal' : 'Info Sistem'),
      message: message,
      type: type,
      timestamp: DateTime.now(),
      poolName: currentPool?.name ?? 'Sistem',
    );
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }
}