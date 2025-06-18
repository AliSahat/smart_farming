import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import '../../../models/pool_model.dart';
import '../database_config.dart';
import '../sql_queries.dart';
import '../database_exception.dart';

class PoolRepository {
  final Database _database;

  PoolRepository(this._database);

  // Insert pool
  Future<int> insertPool({required String key, required Pool pool}) async {
    try {
      final data = {
        DatabaseConfig.poolKey: key,
        DatabaseConfig.poolName: pool.name,
        DatabaseConfig.poolDepth: pool.depth,
        DatabaseConfig.poolNormalLevel: pool.normalLevel,
        DatabaseConfig.poolMaxLevel: pool.maxLevel,
        DatabaseConfig.poolMinLevel: pool.minLevel,
        DatabaseConfig.poolCurrentDepth: pool.currentDepth,
        DatabaseConfig.poolCreatedAt: DateTime.now().toIso8601String(),
        DatabaseConfig.poolUpdatedAt: DateTime.now().toIso8601String(),
      };

      final result = await _database.insert(
        DatabaseConfig.poolsTable,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      debugPrint('Pool inserted: $key');
      return result;
    } catch (e) {
      debugPrint('Error inserting pool: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Get all pools
  Future<Map<String, Pool>> getAllPools() async {
    try {
      final List<Map<String, dynamic>> maps = await _database.rawQuery(
        SqlQueries.getAllPools,
      );

      debugPrint('Retrieved ${maps.length} pools');

      final Map<String, Pool> pools = {};
      for (var map in maps) {
        try {
          final pool = _mapToPool(map);
          pools[map[DatabaseConfig.poolKey]] = pool;
        } catch (e) {
          debugPrint('Error parsing pool ${map[DatabaseConfig.poolKey]}: $e');
        }
      }

      return pools;
    } catch (e) {
      debugPrint('Error getting pools: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Get pool by key
  Future<Pool?> getPoolByKey(String key) async {
    try {
      final List<Map<String, dynamic>> maps = await _database.rawQuery(
        SqlQueries.getPoolByKey,
        [key],
      );

      if (maps.isEmpty) return null;

      return _mapToPool(maps.first);
    } catch (e) {
      debugPrint('Error getting pool by key: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Update pool
  Future<int> updatePool({required String key, required Pool pool}) async {
    try {
      final data = {
        DatabaseConfig.poolName: pool.name,
        DatabaseConfig.poolDepth: pool.depth,
        DatabaseConfig.poolNormalLevel: pool.normalLevel,
        DatabaseConfig.poolMaxLevel: pool.maxLevel,
        DatabaseConfig.poolMinLevel: pool.minLevel,
        DatabaseConfig.poolCurrentDepth: pool.currentDepth,
        DatabaseConfig.poolUpdatedAt: DateTime.now().toIso8601String(),
      };

      final result = await _database.update(
        DatabaseConfig.poolsTable,
        data,
        where: '${DatabaseConfig.poolKey} = ?',
        whereArgs: [key],
      );

      debugPrint('Pool updated: $key');
      return result;
    } catch (e) {
      debugPrint('Error updating pool: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Update current depth only
  Future<int> updateCurrentDepth({
    required String key,
    required double currentDepth,
  }) async {
    try {
      final result = await _database.rawUpdate(
        SqlQueries.updatePoolCurrentDepth,
        [currentDepth, DateTime.now().toIso8601String(), key],
      );

      return result;
    } catch (e) {
      debugPrint('Error updating current depth: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Delete pool
  Future<int> deletePool(String key) async {
    try {
      final result = await _database.rawDelete(SqlQueries.deletePoolByKey, [
        key,
      ]);

      debugPrint('Pool deleted: $key');
      return result;
    } catch (e) {
      debugPrint('Error deleting pool: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Get pool count
  Future<int> getPoolCount() async {
    try {
      final result = await _database.rawQuery(SqlQueries.getPoolCount);
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Error getting pool count: $e');
      return 0;
    }
  }

  // Helper method to map database result to Pool model
  Pool _mapToPool(Map<String, dynamic> map) {
    return Pool(
      name: map[DatabaseConfig.poolName],
      depth: (map[DatabaseConfig.poolDepth] as num).toDouble(),
      normalLevel: (map[DatabaseConfig.poolNormalLevel] as num).toDouble(),
      maxLevel: (map[DatabaseConfig.poolMaxLevel] as num).toDouble(),
      minLevel: (map[DatabaseConfig.poolMinLevel] as num).toDouble(),
      currentDepth: (map[DatabaseConfig.poolCurrentDepth] as num).toDouble(),
    );
  }
}
