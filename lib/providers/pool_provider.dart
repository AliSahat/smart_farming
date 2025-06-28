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

  bool _isManualMode = false;

  bool get isManualMode => _isManualMode;
  set isManualMode(bool value) => _isManualMode = value;

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
    if (!hasValidSelection || _isManualMode) return;
    final pool = currentPool!;
    ValveStatus previousValveStatus = _valveStatus;
    DrainStatus previousDrainStatus = _drainStatus;

    // Logika yang diperbarui sesuai kebutuhan:
    // 1. Jika level air di bawah normal (termasuk di bawah minimum) -> keran utama terbuka
    // 2. Jika level air sudah mencapai/di atas normal tapi di bawah maksimum -> keran utama tertutup
    // 3. Jika level air di atas maksimum -> keran pembuangan terbuka dan keran utama tertutup

    // Logika untuk keran utama: terbuka selama belum mencapai level normal
    if (pool.currentDepth < pool.normalLevel) {
      // Keran utama terbuka selama air belum mencapai level normal
      _valveStatus = ValveStatus.open;

      if (pool.isLevelTooLow) {
        // Jika level air di bawah batas minimum
        Logger.i(
          "🔄 Water level too LOW (${pool.currentDepth.toStringAsFixed(1)}cm < ${pool.minLevel.toStringAsFixed(1)}cm) - Opening main valve",
        );
      } else {
        // Level air sudah di atas minimum tapi belum mencapai normal
        Logger.i(
          "🔄 Water level between MIN and NORMAL (${pool.currentDepth.toStringAsFixed(1)}cm vs ${pool.normalLevel.toStringAsFixed(1)}cm) - Keeping main valve open",
        );
      }

      // Keran pembuangan selalu tertutup jika air di bawah normal
      _drainStatus = DrainStatus.closed;
    } else if (pool.isLevelTooHigh) {
      // Jika level air di atas batas maksimum
      _valveStatus = ValveStatus
          .closed; // Keran utama tertutup untuk menghentikan pengisian
      _drainStatus =
          DrainStatus.open; // Keran pembuangan terbuka untuk mengurangi air

      Logger.i(
        "🔄 Water level too HIGH (${pool.currentDepth.toStringAsFixed(1)}cm) - Opening drain valve",
      );
    } else {
      // Jika level air sudah normal (di atas atau sama dengan normalLevel dan di bawah maxLevel)
      _valveStatus = ValveStatus.closed; // Keran utama tertutup
      _drainStatus = DrainStatus.closed; // Keran pembuangan tertutup

      Logger.i(
        "✅ Water level NORMAL (${pool.currentDepth.toStringAsFixed(1)}cm between ${pool.normalLevel.toStringAsFixed(1)}cm and ${pool.maxLevel.toStringAsFixed(1)}cm) - All valves closed",
      );
    }

    _safetyTimer?.cancel();
    if (isSafetyTimerEnabled &&
        (_valveStatus == ValveStatus.open ||
            _drainStatus == DrainStatus.open)) {
      _safetyTimer = Timer(_maxDuration, () {
        onNotification(
          _createNotification(
            'Aksi berjalan terlalu lama! Sistem dihentikan demi keamanan.',
            'error',
          ),
        );
        _valveStatus = ValveStatus.closed;
        _drainStatus = DrainStatus.closed;
        notifyListeners();
        Logger.e("SAFETY TIMEOUT: All valves closed.");
      });
    }

    if ((_valveStatus != previousValveStatus ||
        _drainStatus != previousDrainStatus)) {
      final depthCm = pool.currentDepth.toStringAsFixed(1);
      final normalCm = pool.normalLevel.toStringAsFixed(1);

      if (_valveStatus == ValveStatus.open &&
          previousValveStatus != ValveStatus.open) {
        // Notifikasi ketika keran utama mulai dibuka
        if (pool.currentDepth < pool.minLevel) {
          // Notifikasi jika air di bawah minimum
          onNotification(
            _createNotification(
              'Level air di bawah batas minimum (${depthCm}cm). Kran utama dibuka untuk pengisian.',
              'warning',
            ),
          );
        } else {
          // Notifikasi jika air di atas minimum tapi belum mencapai normal
          onNotification(
            _createNotification(
              'Level air belum mencapai target normal (${depthCm}cm vs ${normalCm}cm). Kran utama dibuka untuk pengisian lanjutan.',
              'info',
            ),
          );
        }
      } else if (_drainStatus == DrainStatus.open &&
          previousDrainStatus != DrainStatus.open) {
        // Notifikasi ketika keran pembuangan mulai dibuka (level melebihi maksimum)
        onNotification(
          _createNotification(
            'Level air melebihi batas maksimum (${depthCm}cm). Pembuangan dibuka untuk mengurangi air.',
            'warning',
          ),
        );
      } else if (_valveStatus == ValveStatus.closed &&
          previousValveStatus == ValveStatus.open) {
        // Notifikasi ketika keran utama ditutup setelah mencapai level normal
        onNotification(
          _createNotification(
            'Level air sudah mencapai target normal (${depthCm}cm >= ${normalCm}cm). Kran utama ditutup.',
            'success',
          ),
        );
      } else if (_drainStatus == DrainStatus.closed &&
          previousDrainStatus == DrainStatus.open) {
        // Notifikasi ketika keran pembuangan ditutup setelah level air normal kembali
        onNotification(
          _createNotification(
            'Level air sudah turun ke level aman (${depthCm}cm). Pembuangan ditutup.',
            'success',
          ),
        );
      }
    }
    notifyListeners();
  }

  void updateCurrentWaterLevel({
    required double distanceToWater,
    required Function(NotificationItem) onNotification, // Ubah tipe ini
    required bool isSafetyTimerEnabled,
  }) {
    if (!hasValidSelection) return;

    final pool = currentPool!;
    final tankDepth = pool.depth;
    final currentWaterDepth = tankDepth - distanceToWater;

    _pools[_selectedPoolKey] = pool.copyWith(currentDepth: currentWaterDepth);

    checkWaterLevelAndControl(
      onNotification: onNotification,
      isSafetyTimerEnabled: isSafetyTimerEnabled,
    );

    notifyListeners();
  }

  void simulateWaterLevelChange({
    required double changeInCm,
    required Function(NotificationItem) onNotification,
    required bool isSafetyTimerEnabled,
  }) {
    if (hasValidSelection) {
      final pool = currentPool!;
      pool.currentDepth = (pool.currentDepth + changeInCm).clamp(
        0.0,
        pool.depth,
      );
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
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePool(String key, Pool pool) async {
    try {
      if (!_pools.containsKey(key)) return false;
      await _dbHelper.updatePool(key, pool);
      _pools[key] = pool;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
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
    } catch (e) {
      return false;
    }
  }

  void selectPool(String key) {
    if (_pools.containsKey(key)) {
      _selectedPoolKey = key;
      // Panggil checkWaterLevelAndControl tanpa notifikasi saat hanya ganti kolam
      checkWaterLevelAndControl(
        onNotification: (_) {},
        isSafetyTimerEnabled: false,
      );
      notifyListeners();
    }
  }

  NotificationItem _createNotification(String message, String type) {
    return NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: type == 'warning'
          ? 'Peringatan Level Air'
          : (type == 'success' ? 'Status Normal' : 'Info Sistem'),
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

  void setManualMode(
    bool isActive, {
    required void Function(NotificationItem notification) onNotification,
  }) {
    if (!hasValidSelection) return;

    isManualMode = isActive;

    if (isActive) {
      // Ketika mode manual diaktifkan, beri notifikasi dan jaga status keran
      onNotification(
        _createNotification(
          'Mode manual diaktifkan. Sistem tidak akan mengontrol otomatis.',
          'info',
        ),
      );
    } else {
      // Ketika mode manual dinonaktifkan, kembalikan ke kontrol otomatis
      onNotification(
        _createNotification(
          'Mode otomatis diaktifkan. Sistem akan mengontrol sesuai level air.',
          'info',
        ),
      );

      // Segera check water level untuk mengatur status keran sesuai kondisi air
      checkWaterLevelAndControl(
        onNotification: onNotification,
        isSafetyTimerEnabled: true,
      );
    }

    notifyListeners();
  }

  void manualSetValve(
    ValveStatus status, {
    required void Function(NotificationItem notification) onNotification,
  }) {
    if (!hasValidSelection || !isManualMode) return;

    final previousStatus = _valveStatus;
    _valveStatus = status;

    if (status != previousStatus) {
      final statusText = status == ValveStatus.open ? 'dibuka' : 'ditutup';
      onNotification(
        _createNotification('Kran utama $statusText secara manual.', 'info'),
      );
    }

    notifyListeners();
  }

  void manualSetDrain(
    DrainStatus status, {
    required void Function(NotificationItem notification) onNotification,
  }) {
    if (!hasValidSelection || !isManualMode) return;

    final previousStatus = _drainStatus;
    _drainStatus = status;

    if (status != previousStatus) {
      final statusText = status == DrainStatus.open ? 'dibuka' : 'ditutup';
      onNotification(
        _createNotification('Pembuangan $statusText secara manual.', 'info'),
      );
    }

    notifyListeners();
  }

  // Helper untuk UI - Status Valve dalam bentuk teks
  String getValveStatusText() {
    switch (_valveStatus) {
      case ValveStatus.open:
        return 'TERBUKA';
      case ValveStatus.closed:
        return 'TERTUTUP';
      case ValveStatus.auto:
        return 'OTOMATIS';
    }
  }

  // Helper untuk UI - Status Drain dalam bentuk teks
  String getDrainStatusText() {
    switch (_drainStatus) {
      case DrainStatus.open:
        return 'TERBUKA';
      case DrainStatus.closed:
        return 'TERTUTUP';
    }
  }

  // Helper untuk UI - Mendapatkan deskripsi status ketinggian air
  String getWaterLevelStatusDescription() {
    if (!hasValidSelection) return 'Tidak ada kolam dipilih';
    final pool = currentPool!;

    // Menggunakan deskripsi yang lebih detail dari model Pool
    return pool.waterLevelDescription;
  }

  // Helper untuk menjelaskan status kontrol berdasarkan level air dan mode
  String getControlStatusDescription() {
    if (!hasValidSelection) return 'Tidak ada kolam dipilih';
    if (isManualMode)
      return 'Mode manual aktif. Kontrol dilakukan secara manual.';

    final pool = currentPool!;
    final normalCm = pool.normalLevel.toStringAsFixed(1);

    if (pool.currentDepth < pool.normalLevel) {
      return 'Pengisian: Air belum mencapai level normal ($normalCm cm). Keran utama terbuka.';
    } else if (pool.isLevelTooHigh) {
      return 'Pembuangan: Air melebihi batas maksimum. Pembuangan dibuka.';
    } else {
      return 'Level optimal: Air sudah mencapai level normal. Semua keran tertutup.';
    }
  }
}
