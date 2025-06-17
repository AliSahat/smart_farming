// lib/models/pool_model.dart
class Pool {
  String name;
  double maxLevel; // Percentage
  double minLevel; // Percentage
  double normalLevel; // in cm
  double depth; // in cm
  double currentDepth; // in cm

  Pool({
    required this.name,
    required this.maxLevel,
    required this.minLevel,
    required this.normalLevel,
    required this.depth,
    required this.currentDepth,
  });

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
