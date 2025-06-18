class ESPWaterData {
  final double distanceToWater; // Sisa ruang dalam cm (jarak sensor ke air)
  final DateTime timestamp;
  final bool isSuccess;
  final String? errorMessage;

  ESPWaterData({
    required this.distanceToWater,
    required this.timestamp,
    this.isSuccess = true,
    this.errorMessage,
  });

  factory ESPWaterData.error(String message) {
    return ESPWaterData(
      distanceToWater: 0,
      timestamp: DateTime.now(),
      isSuccess: false,
      errorMessage: message,
    );
  }

  // Getter untuk compatibility dengan sensor data card
  bool get isConnected => isSuccess;

  // Getter untuk water level (calculated from distance)
  double get waterLevel {
    // Ini akan dihitung di dashboard berdasarkan pool depth
    // Untuk sekarang return 0, akan diupdate dari dashboard
    return 0.0;
  }

  // Getter untuk pool name (akan diupdate dari dashboard)
  String get poolName => 'Unknown Pool';

  @override
  String toString() {
    return 'ESPWaterData{distanceToWater: $distanceToWater, timestamp: $timestamp, isSuccess: $isSuccess, errorMessage: $errorMessage}';
  }
}
