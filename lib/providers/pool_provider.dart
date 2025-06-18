// ignore_for_file: unused_import, unused_field, prefer_final_fields

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/pool_model.dart';
import '../services/water_control_service.dart';
import '../services/database/database_helper.dart';

// Import ValveStatus dan DrainStatus dari notification_model.dart
import '../models/notification_model.dart' show ValveStatus, DrainStatus;

class PoolProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final WaterControlService _controlService = WaterControlService();

  Map<String, Pool> _pools = {};
  String _selectedPoolKey = '';
  ValveStatus _valveStatus = ValveStatus.auto;
  DrainStatus _drainStatus = DrainStatus.closed;
  bool _isConnected = true;
  bool _isLoading = false;
  Timer? _waterLevelTimer;
  bool _isInitialized = false;

  // Getters
  Map<String, Pool> get pools => _pools;
  String get selectedPoolKey => _selectedPoolKey;
  Pool? get currentPool => _pools[_selectedPoolKey];
  ValveStatus get valveStatus => _valveStatus;
  DrainStatus get drainStatus => _drainStatus;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get hasValidSelection =>
      _selectedPoolKey.isNotEmpty && _pools.containsKey(_selectedPoolKey);
  bool get isEmpty => _pools.isEmpty;

  Future<void> loadPools() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Loading pools from database...');
      _pools = await _dbHelper.getAllPools();

      debugPrint('Loaded ${_pools.length} pools from database');

      // Set selected pool jika ada pools
      if (_pools.isNotEmpty) {
        if (_selectedPoolKey.isEmpty || !_pools.containsKey(_selectedPoolKey)) {
          _selectedPoolKey = _pools.keys.first;
          debugPrint('Selected pool: $_selectedPoolKey');
        }
      } else {
        _selectedPoolKey = '';
        debugPrint('No pools found in database');
      }

      _isInitialized = true;
      debugPrint('Pool loading completed successfully');
    } catch (e) {
      debugPrint('Error loading pools: $e');
      _isInitialized = true;
      _pools = {};
      _selectedPoolKey = '';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updatePoolSettings(Pool updatedPool) {
    if (hasValidSelection) {
      _pools[_selectedPoolKey] = updatedPool;
      notifyListeners();
    }
  }

  void startWaterLevelSimulation() {
    if (_pools.isEmpty) return;

    _waterLevelTimer?.cancel();
    _waterLevelTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (hasValidSelection) {
        // Simulate water level changes
        final pool = currentPool!;
        final randomChange = (Random().nextDouble() - 0.5) * 2;
        pool.currentDepth = (pool.currentDepth + randomChange).clamp(
          0,
          pool.depth,
        );

        // Update database
        _dbHelper.updatePoolCurrentDepth(_selectedPoolKey, pool.currentDepth);

        // Auto control logic
        if (_valveStatus == ValveStatus.auto) {
          _checkWaterLevelAndControl();
        }

        notifyListeners();
      }
    });
  }

  void _checkWaterLevelAndControl() {
    if (!hasValidSelection) return;

    final pool = currentPool!;

    if (pool.isLevelTooLow) {
      _valveStatus = ValveStatus.open;
      _drainStatus = DrainStatus.closed;
    } else if (pool.isLevelTooHigh) {
      _valveStatus = ValveStatus.closed;
      _drainStatus = DrainStatus.open;
    } else {
      _valveStatus = ValveStatus.auto;
      _drainStatus = DrainStatus.closed;
    }
  }

  void setValveStatus(ValveStatus status) {
    _valveStatus = status;
    notifyListeners();
  }

  void setDrainStatus(DrainStatus status) {
    _drainStatus = status;
    notifyListeners();
  }

  Future<bool> addPool(String key, Pool pool) async {
    try {
      // Validasi key unik
      if (_pools.containsKey(key)) {
        debugPrint('Pool key already exists: $key');
        return false;
      }

      await _dbHelper.insertPool(key, pool);
      _pools[key] = pool;

      // Jika ini pool pertama, set sebagai selected
      if (_pools.length == 1) {
        _selectedPoolKey = key;
        // Start simulation untuk pool pertama
        startWaterLevelSimulation();
      }

      notifyListeners();
      debugPrint('Pool added successfully: $key');
      return true;
    } catch (e) {
      debugPrint('Error adding pool: $e');
      return false;
    }
  }

  Future<bool> updatePool(String key, Pool pool) async {
    try {
      if (!_pools.containsKey(key)) {
        debugPrint('Pool not found for update: $key');
        return false;
      }

      await _dbHelper.updatePool(key, pool);
      _pools[key] = pool;
      notifyListeners();
      debugPrint('Pool updated successfully: $key');
      return true;
    } catch (e) {
      debugPrint('Error updating pool: $e');
      return false;
    }
  }

  Future<bool> deletePool(String key) async {
    try {
      if (!_pools.containsKey(key)) {
        debugPrint('Pool not found for deletion: $key');
        return false;
      }

      await _dbHelper.deletePool(key);
      _pools.remove(key);

      // Update selected pool jika yang dihapus sedang dipilih
      if (_selectedPoolKey == key) {
        if (_pools.isNotEmpty) {
          _selectedPoolKey = _pools.keys.first;
        } else {
          _selectedPoolKey = '';
          // Stop simulation jika tidak ada pool
          _waterLevelTimer?.cancel();
        }
      }

      notifyListeners();
      debugPrint('Pool deleted successfully: $key');
      return true;
    } catch (e) {
      debugPrint('Error deleting pool: $e');
      return false;
    }
  }

  void selectPool(String key) {
    if (_pools.containsKey(key)) {
      _selectedPoolKey = key;
      notifyListeners();
      debugPrint('Pool selected: $key');
    }
  }

  Future<void> addHistoryEntry({
    required String event,
    required String eventType,
    required double waterLevel,
    required String details,
  }) async {
    if (hasValidSelection) {
      try {
        await _dbHelper.insertHistory(
          poolKey: _selectedPoolKey,
          event: event,
          eventType: eventType,
          waterLevel: waterLevel,
          details: details,
        );
      } catch (e) {
        debugPrint('Error adding history entry: $e');
      }
    }
  }

  // Get database statistics
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    return await _dbHelper.getDatabaseInfo();
  }

  @override
  void dispose() {
    _waterLevelTimer?.cancel();
    super.dispose();
  }
}
