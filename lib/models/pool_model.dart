// lib/models/pool_model.dart
import 'dart:core';

class Pool {
  final String name;
  final double depth;
  final double normalLevel;
  final double maxLevel;
  final double minLevel;
  double currentDepth;

  Pool({
    required this.name,
    required this.depth,
    required this.normalLevel,
    required this.maxLevel,
    required this.minLevel,
    this.currentDepth = 0.0,
  });

  // Getter methods untuk status level air
  bool get isLevelTooLow {
    final minDepthCm = (minLevel / 100) * depth;
    return currentDepth < minDepthCm;
  }

  bool get isLevelTooHigh {
    final maxDepthCm = (maxLevel / 100) * depth;
    return currentDepth > maxDepthCm;
  }

  bool get isLevelNormal {
    final minDepthCm = (minLevel / 100) * depth;
    final maxDepthCm = (maxLevel / 100) * depth;
    return currentDepth >= minDepthCm && currentDepth <= maxDepthCm;
  }

  // Menghitung persentase level air saat ini
  double get currentLevelPercent {
    return (currentDepth / depth * 100).clamp(0.0, 100.0);
  }

  // Status level dalam string
  String get levelStatus {
    if (isLevelTooLow) return 'Rendah';
    if (isLevelTooHigh) return 'Berlebihan';
    return 'Normal';
  }

  // Warna untuk status level
  String get levelStatusColor {
    if (isLevelTooLow) return 'red';
    if (isLevelTooHigh) return 'orange';
    return 'green';
  }

  Pool copyWith({
    String? name,
    double? depth,
    double? normalLevel,
    double? maxLevel,
    double? minLevel,
    double? currentDepth,
  }) {
    return Pool(
      name: name ?? this.name,
      depth: depth ?? this.depth,
      normalLevel: normalLevel ?? this.normalLevel,
      maxLevel: maxLevel ?? this.maxLevel,
      minLevel: minLevel ?? this.minLevel,
      currentDepth: currentDepth ?? this.currentDepth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'depth': depth,
      'normalLevel': normalLevel,
      'maxLevel': maxLevel,
      'minLevel': minLevel,
      'currentDepth': currentDepth,
    };
  }

  factory Pool.fromMap(Map<String, dynamic> map) {
    return Pool(
      name: map['name'],
      depth: map['depth'],
      normalLevel: map['normalLevel'],
      maxLevel: map['maxLevel'],
      minLevel: map['minLevel'],
      currentDepth: map['currentDepth'] ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'Pool(name: $name, depth: $depth, currentDepth: $currentDepth)';
  }
}
