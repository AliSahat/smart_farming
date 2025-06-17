import '../models/pool_model.dart';

enum ValveStatus { open, closed, auto }
enum DrainStatus { open, closed }

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
}