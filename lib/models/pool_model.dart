// lib/models/pool_model.dart
// VERSI PERBAIKAN FINAL - min/max sekarang dalam CM
import 'dart:core';

class Pool {
  final String name;
  final double depth; // Kedalaman total dalam cm
  final double normalLevel; // Target normal dalam cm
  final double maxLevel; // Batas MAKSIMUM dalam cm (bukan persen)
  final double minLevel; // Batas MINIMUM dalam cm (bukan persen)
  double currentDepth; // Ketinggian air saat ini dalam cm

  Pool({
    required this.name,
    required this.depth,
    required this.normalLevel,
    required this.maxLevel,
    required this.minLevel,
    this.currentDepth = 0.0,
  });

  // Getter methods untuk status level air
  // Logikanya sekarang membandingkan cm dengan cm secara langsung
  bool get isLevelTooLow {
    // Ketinggian air lebih rendah dari batas minimum yang ditentukan dalam cm
    return currentDepth < minLevel;
  }

  bool get isLevelTooHigh {
    // Ketinggian air lebih tinggi dari batas maksimum yang ditentukan dalam cm
    return currentDepth > maxLevel;
  }

  bool get isLevelNormal {
    // Kondisi aman adalah ketika air berada di antara batas min dan max
    return !isLevelTooLow && !isLevelTooHigh;
  }

  // Menghitung persentase level air saat ini untuk ditampilkan di UI
  double get currentLevelPercent {
    if (depth == 0) return 0; // Hindari pembagian dengan nol
    return (currentDepth / depth * 100).clamp(0.0, 100.0);
  }

  // Status level dalam string
  String get levelStatus {
    if (isLevelTooLow) return 'Rendah';
    if (isLevelTooHigh) return 'Berlebih';
    return 'Normal';
  }

  // (Sisa kode seperti copyWith, toMap, dll. tetap sama)
  // ...
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
