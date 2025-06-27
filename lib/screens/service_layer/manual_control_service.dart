import 'package:smart_farming/helper/notification_service.dart';
import 'package:logger/logger.dart';

class ManualControlService {
  final NotificationService _notificationService;

  ManualControlService(this._notificationService);

  Future<bool> togglePump(bool currentState, String? poolName) async {
    final newState = !currentState;
    Logger().i(
      "🔄 Toggling pump: ${currentState ? 'ON→OFF' : 'OFF→ON'} for $poolName",
    );

    _notificationService.addPumpNotification(
      newState,
      'Manual Control',
      type: 'info',
      poolName: poolName,
    );

    // TODO: Implement actual ESP32 pump control
    await Future.delayed(const Duration(milliseconds: 500));
    Logger().i("✅ Pump state changed to: ${newState ? 'ON' : 'OFF'}");
    return newState;
  }

  Future<bool> toggleValve(bool currentState, String? poolName) async {
    final newState = !currentState;
    Logger().i(
      "🔄 Toggling valve: ${currentState ? 'OPEN→CLOSE' : 'CLOSE→OPEN'} for $poolName",
    );

    _notificationService.addValveNotification(
      newState,
      'Manual Control',
      type: newState ? 'warning' : 'info',
      poolName: poolName,
    );

    // TODO: Implement actual ESP32 valve control
    await Future.delayed(const Duration(milliseconds: 500));
    Logger().i("✅ Valve state changed to: ${newState ? 'OPEN' : 'CLOSED'}");
    return newState;
  }

  Future<Map<String, bool>> activateFillMode(String? poolName) async {
    Logger().i("🔵 Activating fill mode for $poolName");

    _notificationService.addSystemNotification(
      'Mode pengisian air diaktifkan',
      'info',
      poolName: poolName,
    );

    _notificationService.addValveNotification(
      false,
      'Mode Pengisian',
      type: 'info',
      poolName: poolName,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    Logger().i("✅ Fill mode activated - PUMP:ON, VALVE:OFF");
    return {
      'isPumpRunning': true,
      'isValveOpen': false,
      'isFillModeActive': true,
      'isDrainModeActive': false,
    };
  }

  Future<Map<String, bool>> deactivateFillMode(String? poolName) async {
    _notificationService.addSystemNotification(
      'Mode pengisian air dinonaktifkan',
      'info',
      poolName: poolName,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'isPumpRunning': false,
      'isValveOpen': false,
      'isFillModeActive': false,
      'isDrainModeActive': false,
    };
  }

  Future<Map<String, bool>> activateDrainMode(String? poolName) async {
    Logger().i("🟡 Activating drain mode for $poolName");

    _notificationService.addSystemNotification(
      'Mode pengosongan air diaktifkan',
      'info',
      poolName: poolName,
    );

    _notificationService.addValveNotification(
      true,
      'Mode Pengosongan',
      type: 'warning',
      poolName: poolName,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    Logger().i("✅ Drain mode activated - PUMP:OFF, VALVE:ON");
    return {
      'isPumpRunning': false,
      'isValveOpen': true,
      'isFillModeActive': false,
      'isDrainModeActive': true,
    };
  }

  Future<Map<String, bool>> deactivateDrainMode(String? poolName) async {
    _notificationService.addSystemNotification(
      'Mode pengosongan air dinonaktifkan',
      'info',
      poolName: poolName,
    );

    _notificationService.addValveNotification(
      false,
      'Mode Pengosongan Off',
      type: 'info',
      poolName: poolName,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    return {
      'isPumpRunning': false,
      'isValveOpen': false,
      'isFillModeActive': false,
      'isDrainModeActive': false,
    };
  }

  Future<Map<String, bool>> emergencyStop(String? poolName) async {
    Logger().w("⚠️ EMERGENCY STOP activated for $poolName");

    _notificationService.addSystemNotification(
      'STOP DARURAT - Semua sistem dimatikan',
      'error',
      poolName: poolName,
    );

    _notificationService.addValveNotification(
      false,
      'Emergency Stop',
      type: 'error',
      poolName: poolName,
    );

    await Future.delayed(const Duration(milliseconds: 500));

    Logger().i("✅ Emergency stop completed - All systems OFF");
    return {
      'isPumpRunning': false,
      'isValveOpen': false,
      'isFillModeActive': false,
      'isDrainModeActive': false,
    };
  }
}
