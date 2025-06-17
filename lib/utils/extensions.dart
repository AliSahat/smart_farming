import 'package:flutter/material.dart';

extension ColorX on Color {
  Color darken([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
  
  Color lighten([double amount = 0.1]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}

extension DoubleX on double {
  String toStringWithPrecision(int precision) {
    return toStringAsFixed(precision);
  }
}