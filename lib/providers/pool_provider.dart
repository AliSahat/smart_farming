import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pool_model.dart';
import '../models/notification_model.dart';
import '../services/water_control_service.dart';

class PoolProvider with ChangeNotifier {
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
  
  String _selectedPoolKey = 'aquarium';
  ValveStatus _valveStatus = ValveStatus.auto;
  DrainStatus _drainStatus = DrainStatus.closed;
  bool _isConnected = true;
  Timer? _waterLevelTimer;
  final WaterControlService _controlService = WaterControlService();
  
  // Getters
  Map<String, Pool> get poolSettings => _poolSettings;
  String get selectedPoolKey => _selectedPoolKey;
  Pool get currentPool => _poolSettings[_selectedPoolKey]!;
  ValveStatus get valveStatus => _valveStatus;
  DrainStatus get drainStatus => _drainStatus;
  bool get isConnected => _isConnected;
  
  // Methods
  void selectPool(String poolKey) {
    _selectedPoolKey = poolKey;
    notifyListeners();
  }
  
  void updatePoolSettings(Pool updatedPool) {
    _poolSettings[_selectedPoolKey] = updatedPool;
    notifyListeners();
  }
  
  void startWaterLevelSimulation() {
    _waterLevelTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      // Simulate water level changes
      final pool = currentPool;
      final randomChange = (Random().nextDouble() - 0.5) * 2;
      pool.currentDepth = (pool.currentDepth + randomChange).clamp(0, pool.depth);
      
      // Auto control logic
      if (_valveStatus == ValveStatus.auto) {
        _checkWaterLevelAndControl();
      }
      
      notifyListeners();
    });
  }
  
  void _checkWaterLevelAndControl() {
    final pool = currentPool;
    
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
  
  @override
  void dispose() {
    _waterLevelTimer?.cancel();
    super.dispose();
  }
}