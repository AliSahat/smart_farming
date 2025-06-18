import 'package:flutter/material.dart';

class PoolData {
  static IconData getPoolIcon(String poolName) {
    final name = poolName.toLowerCase();

    if (name.contains('aquarium')) {
      return Icons.water;
    } else if (name.contains('kolam')) {
      return Icons.pool;
    } else if (name.contains('tank') || name.contains('tangki')) {
      return Icons.storage;
    } else if (name.contains('reservoir') || name.contains('waduk')) {
      return Icons.water_drop;
    } else {
      return Icons.water_damage;
    }
  }

  static Color getPoolColor(String poolName) {
    final name = poolName.toLowerCase();

    if (name.contains('aquarium')) {
      return Colors.cyan;
    } else if (name.contains('kolam')) {
      return Colors.blue;
    } else if (name.contains('tank') || name.contains('tangki')) {
      return Colors.indigo;
    } else if (name.contains('reservoir') || name.contains('waduk')) {
      return Colors.lightBlue;
    } else {
      return Colors.blueGrey;
    }
  }
}
