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

  @override
  String toString() {
    return 'ESPWaterData{distanceToWater: $distanceToWater, timestamp: $timestamp, isSuccess: $isSuccess, errorMessage: $errorMessage}';
  }
}
