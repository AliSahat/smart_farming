import '../models/pool_model.dart';
import '../models/notification_model.dart' show ValveStatus, DrainStatus;

class WaterControlService {
  ValveStatus getRecommendedValveStatus(Pool pool) {
    if (pool.isLevelTooLow) {
      return ValveStatus.open;
    } else if (pool.isLevelTooHigh) {
      return ValveStatus.closed;
    }
    return ValveStatus.auto;
  }

  DrainStatus getRecommendedDrainStatus(Pool pool) {
    if (pool.isLevelTooHigh) {
      return DrainStatus.open;
    }
    return DrainStatus.closed;
  }

  String getValveStatusText(ValveStatus status) {
    switch (status) {
      case ValveStatus.open:
        return 'TERBUKA';
      case ValveStatus.closed:
        return 'TERTUTUP';
      case ValveStatus.auto:
        return 'OTOMATIS';
    }
  }

  String getDrainStatusText(DrainStatus status) {
    switch (status) {
      case DrainStatus.open:
        return 'TERBUKA';
      case DrainStatus.closed:
        return 'TERTUTUP';
    }
  }

  // Service untuk mengontrol valve dan drain
  Future<bool> openValve() async {
    // Implementasi kontrol valve
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> closeValve() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> openDrain() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> closeDrain() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
