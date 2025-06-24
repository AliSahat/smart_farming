// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

// Use the newer approach with ThemeData.from and then copyWith
final lightThemeData =
    ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        primary: Colors.blue,
        secondary: Colors.orange,
      ),
    ).copyWith(
      // Skip direct cardTheme setting as it causes type conflicts
      // and use useMaterial3 to get modern card styling
      useMaterial3: true,

      // These should still work as before
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );

// Define card styling to be applied individually to cards
class AppCardStyles {
  static ShapeBorder get defaultShape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

  static double get defaultElevation => 2.0;
}
