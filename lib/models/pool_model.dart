// lib/models/pool_model.dart
import 'dart:core';

class Pool {
  final String name;
  final double maxLevel; // Percentage
  final double minLevel; // Percentage
  final double normalLevel; // in cm
  final double depth; // in cm
  double currentDepth; // in cm

  Pool({
    required this.name,
    required this.maxLevel,
    required this.minLevel,
    required this.normalLevel,
    required this.depth,
    required this.currentDepth,
  });

  double get waterLevelPercent => (currentDepth / depth) * 100;
  
  bool get isLevelTooLow => waterLevelPercent < minLevel;
  bool get isLevelTooHigh => waterLevelPercent > maxLevel;
  bool get isLevelNormal => !isLevelTooLow && !isLevelTooHigh;
  
  double get remainingSpace => depth - currentDepth;

  // Helper method to create a copy with updated values
  Pool copyWith({
    String? name,
    double? maxLevel,
    double? minLevel,
    double? normalLevel,
    double? depth,
    double? currentDepth,
  }) {
    return Pool(
      name: name ?? this.name,
      maxLevel: maxLevel ?? this.maxLevel,
      minLevel: minLevel ?? this.minLevel,
      normalLevel: normalLevel ?? this.normalLevel,
      depth: depth ?? this.depth,
      currentDepth: currentDepth ?? this.currentDepth,
    );
  }
}
