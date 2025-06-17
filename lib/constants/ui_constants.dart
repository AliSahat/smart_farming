// lib/models/pool_model.dart
import 'dart:core';
import 'package:flutter/material.dart';

class Pool {
  static const double tiny = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double regular = 16.0;
  static const double large = 20.0;
  static const double extraLarge = 24.0;
  static const double huge = 32.0;

  final String name;
  double maxLevel; // Percentage
  double minLevel; // Percentage
  double normalLevel; // in cm
  double depth; // in cm
  double currentDepth; // in cm

  Pool({
    required this.name,
    this.maxLevel = 8.0,
    this.minLevel = 12.0,
    this.normalLevel = 16.0,
    this.depth = 20.0,
    this.currentDepth = 0.0,
  });
}

class AppSpacing {
  static const double tiny = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double regular = 16.0;
  static const double large = 20.0;
  static const double extraLarge = 24.0;
  static const double huge = 32.0;
}

class AppRadius {
  static const double small = 8.0;
  static const double regular = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 20.0;
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body = TextStyle(fontSize: 14);
  static const TextStyle caption = TextStyle(fontSize: 12, color: Colors.grey);
}
