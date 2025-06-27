// lib/providers/pool_provider.dart
// VERSI PERBAIKAN - Menambahkan Logika Mode Manual
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_farming/utils/logger.dart';
import '../models/pool_model.dart';
import '../services/database/database_helper.dart';
import '../models/notification_model.dart';

class PoolProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // --- STATE ---
  Map<String, Pool> _pools = {};
  String _selectedPoolKey = '';
  ValveStatus _valveStatus = ValveStatus.closed;
  DrainStatus _drainStatus = DrainStatus.closed;
  bool _isLoading = false;
  bool _isInitialized = false;

  // State baru untuk mode manual
  bool _isManualMode = false;

  Timer? _safetyTimer;
  final Duration _maxDuration = const Duration(minutes: 15);

  // --- GETTERS ---
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
  // Getter baru
  bool get isManualMode => _isManualMode;

  // ... (Fungsi loadPools, addPool, updatePool, deletePool, selectPool tetap sama)

  // --- LOGIC & CONTROL ---

  /// Mengatur mode manual dan menjalankan ulang pengecekan otomatis jika kembali ke mode auto
  void setManualMode(
    bool isManual, {
    required Function(NotificationItem) onNotification,
  }) {
    _isManualMode = isManual;
    Logger.d("Mode manual diubah menjadi: $_isManualMode");

    if (!_isManualMode) {
      // Jika kembali ke mode otomatis, langsung jalankan pengecekan
      onNotification(
        _createNotification("Sistem kembali ke mode otomatis.", "info"),
      );
      checkWaterLevelAndControl(
        onNotification: onNotification,
        isSafetyTimerEnabled: true,
      ); // Asumsi timer aktif
    } else {
      onNotification(
        _createNotification("Sistem beralih ke mode kontrol manual.", "info"),
      );
    }
    notifyListeners();
  }

  // Fungsi-fungsi baru untuk aksi manual
  void manualSetValve(
    ValveStatus status, {
    required Function(NotificationItem) onNotification,
  }) {
    if (!_isManualMode) return;
    _valveStatus = status;
    onNotification(
      _createNotification("Kran utama diatur manual ke: $status", "info"),
    );
    notifyListeners();
  }

  void manualSetDrain(
    DrainStatus status, {
    required Function(NotificationItem) onNotification,
  }) {
    if (!_isManualMode) return;
    _drainStatus = status;
    onNotification(
      _createNotification("Pembuangan diatur manual ke: $status", "info"),
    );
    notifyListeners();
  }

  /// Logika kontrol otomatis, hanya berjalan jika mode manual TIDAK aktif
  void checkWaterLevelAndControl({
    required Function(NotificationItem) onNotification,
    required bool isSafetyTimerEnabled,
  }) {
    // Kunci utama: Jangan lakukan apapun jika mode manual aktif
    if (_isManualMode || !hasValidSelection) return;

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
      if (_valveStatus == ValveStatus.open) {
        onNotification(
          _createNotification(
            'Level air rendah (${depthCm}cm). Kran dibuka.',
            'warning',
          ),
        );
      } else if (_drainStatus == DrainStatus.open) {
        onNotification(
          _createNotification(
            'Level air tinggi (${depthCm}cm). Pembuangan dibuka.',
            'warning',
          ),
        );
      } else if (previousValveStatus == ValveStatus.open ||
          previousDrainStatus == DrainStatus.open) {
        onNotification(
          _createNotification(
            'Level air normal (${depthCm}cm). Sistem standby.',
            'success',
          ),
        );
      }
    }
    notifyListeners();
  }

  Timer? _notifyTimer;
  bool _hasPendingNotification = false;

  // Debounced notifyListeners
  void _debouncedNotifyListeners() {
    if (_hasPendingNotification) return;

    _hasPendingNotification = true;
    _notifyTimer?.cancel();
    _notifyTimer = Timer(const Duration(milliseconds: 500), () {
      if (_hasPendingNotification) {
        _hasPendingNotification = false;
        notifyListeners();
      }
    });
  }

  void updateCurrentWaterLevel({
    required double distanceToWater,
    required Function(NotificationItem) onNotification,
    required bool isSafetyTimerEnabled,
  }) {
    if (hasValidSelection) {
      final pool = currentPool!;
      final oldDepth = pool.currentDepth;
      pool.currentDepth = (pool.depth - distanceToWater).clamp(0.0, pool.depth);

      // Tingkatkan threshold untuk mengurangi sensitivity
      if ((oldDepth - pool.currentDepth).abs() > 2.0) {
        checkWaterLevelAndControl(
          onNotification: onNotification,
          isSafetyTimerEnabled: isSafetyTimerEnabled,
        );
        _debouncedNotifyListeners(); // Use debounced version
      }
    }
  }

  // Sisa kode (addPool, updatePool, deletePool, selectPool, _createNotification, dispose) tetap sama
  // ...
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
    _notifyTimer?.cancel();
    super.dispose();
  }

  Future<void> loadPools() async {}
}
