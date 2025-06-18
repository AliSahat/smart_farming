import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:flutter/foundation.dart';
import '../../../models/history_model.dart';
import '../database_config.dart';
import '../sql_queries.dart';
import '../database_exception.dart';

class HistoryRepository {
  final sqflite.Database _database;

  HistoryRepository(this._database);

  // Insert history entry
  Future<int> insertHistory({
    required String poolKey,
    required String event,
    required String eventType,
    required double waterLevel,
    required String details,
  }) async {
    try {
      // Get pool ID first
      final poolResult = await _database.query(
        DatabaseConfig.poolsTable,
        columns: [DatabaseConfig.poolId],
        where: '${DatabaseConfig.poolKey} = ?',
        whereArgs: [poolKey],
      );

      if (poolResult.isEmpty) {
        throw DatabaseExceptionHandler.handle('Pool not found: $poolKey');
      }

      final poolId = poolResult.first[DatabaseConfig.poolId] as int;

      final data = {
        DatabaseConfig.historyPoolId: poolId,
        DatabaseConfig.historyEvent: event,
        DatabaseConfig.historyEventType: eventType,
        DatabaseConfig.historyWaterLevel: waterLevel,
        DatabaseConfig.historyDetails: details,
        DatabaseConfig.historyTimestamp: DateTime.now().toIso8601String(),
      };

      final result = await _database.insert(DatabaseConfig.historyTable, data);

      debugPrint('History inserted for pool: $poolKey');
      return result;
    } catch (e) {
      debugPrint('Error inserting history: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Get all history
  Future<List<HistoryEntry>> getAllHistory() async {
    try {
      final List<Map<String, dynamic>> maps = await _database.rawQuery(
        SqlQueries.getHistoryWithPool,
      );

      return maps.map((map) => _mapToHistoryEntry(map)).toList();
    } catch (e) {
      debugPrint('Error getting all history: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Get history by pool key
  Future<List<HistoryEntry>> getHistoryByPoolKey(String poolKey) async {
    try {
      final List<Map<String, dynamic>> maps = await _database.rawQuery(
        SqlQueries.getHistoryByPoolKey,
        [poolKey],
      );

      return maps.map((map) => _mapToHistoryEntry(map)).toList();
    } catch (e) {
      debugPrint('Error getting history by pool key: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Get history with filters
  Future<List<HistoryEntry>> getHistoryWithFilters({
    String? poolKey,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      String sql = SqlQueries.getHistoryWithPool;
      List<String> whereConditions = [];
      List<dynamic> whereArgs = [];

      if (poolKey != null && poolKey != 'semua') {
        whereConditions.add('p.${DatabaseConfig.poolKey} = ?');
        whereArgs.add(poolKey);
      }

      if (startDate != null) {
        whereConditions.add('h.${DatabaseConfig.historyTimestamp} >= ?');
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        whereConditions.add('h.${DatabaseConfig.historyTimestamp} <= ?');
        whereArgs.add(endDate.toIso8601String());
      }

      if (whereConditions.isNotEmpty) {
        sql = sql.replaceFirst(
          'ORDER BY',
          'WHERE ${whereConditions.join(' AND ')} ORDER BY',
        );
      }

      final List<Map<String, dynamic>> maps = await _database.rawQuery(
        sql,
        whereArgs,
      );

      return maps.map((map) => _mapToHistoryEntry(map)).toList();
    } catch (e) {
      debugPrint('Error getting filtered history: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Get history count
  Future<int> getHistoryCount() async {
    try {
      final result = await _database.rawQuery(SqlQueries.getHistoryCount);
      return sqflite.Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Error getting history count: $e');
      return 0;
    }
  }

  // Delete history by pool key
  Future<int> deleteHistoryByPoolKey(String poolKey) async {
    try {
      final poolResult = await _database.query(
        DatabaseConfig.poolsTable,
        columns: [DatabaseConfig.poolId],
        where: '${DatabaseConfig.poolKey} = ?',
        whereArgs: [poolKey],
      );

      if (poolResult.isEmpty) {
        return 0;
      }

      final poolId = poolResult.first[DatabaseConfig.poolId] as int;

      final result = await _database.delete(
        DatabaseConfig.historyTable,
        where: '${DatabaseConfig.historyPoolId} = ?',
        whereArgs: [poolId],
      );

      debugPrint('History deleted for pool: $poolKey');
      return result;
    } catch (e) {
      debugPrint('Error deleting history: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Helper method to map database result to HistoryEntry model
  HistoryEntry _mapToHistoryEntry(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map[DatabaseConfig.historyId],
      poolKey: map['pool_key'],
      poolName: map['pool_name'],
      event: map[DatabaseConfig.historyEvent],
      eventType: map[DatabaseConfig.historyEventType],
      waterLevel: (map[DatabaseConfig.historyWaterLevel] as num).toDouble(),
      details: map[DatabaseConfig.historyDetails],
      timestamp: DateTime.parse(map[DatabaseConfig.historyTimestamp]),
    );
  }
}
