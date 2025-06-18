import 'database_config.dart';

class SqlQueries {
  // Create table queries
  static const String createPoolsTable =
      '''
    CREATE TABLE ${DatabaseConfig.poolsTable} (
      ${DatabaseConfig.poolId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConfig.poolKey} TEXT UNIQUE NOT NULL,
      ${DatabaseConfig.poolName} TEXT NOT NULL,
      ${DatabaseConfig.poolDepth} REAL NOT NULL,
      ${DatabaseConfig.poolNormalLevel} REAL NOT NULL,
      ${DatabaseConfig.poolMaxLevel} REAL NOT NULL,
      ${DatabaseConfig.poolMinLevel} REAL NOT NULL,
      ${DatabaseConfig.poolCurrentDepth} REAL DEFAULT 0,
      ${DatabaseConfig.poolCreatedAt} TEXT DEFAULT CURRENT_TIMESTAMP,
      ${DatabaseConfig.poolUpdatedAt} TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  static const String createHistoryTable =
      '''
    CREATE TABLE ${DatabaseConfig.historyTable} (
      ${DatabaseConfig.historyId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${DatabaseConfig.historyPoolId} INTEGER NOT NULL,
      ${DatabaseConfig.historyEvent} TEXT NOT NULL,
      ${DatabaseConfig.historyEventType} TEXT NOT NULL,
      ${DatabaseConfig.historyWaterLevel} REAL NOT NULL,
      ${DatabaseConfig.historyDetails} TEXT,
      ${DatabaseConfig.historyTimestamp} TEXT NOT NULL,
      FOREIGN KEY (${DatabaseConfig.historyPoolId}) 
        REFERENCES ${DatabaseConfig.poolsTable} (${DatabaseConfig.poolId}) 
        ON DELETE CASCADE
    )
  ''';

  // Pool queries
  static const String getAllPools =
      '''
    SELECT * FROM ${DatabaseConfig.poolsTable} 
    ORDER BY ${DatabaseConfig.poolCreatedAt} ASC
  ''';

  static const String getPoolByKey =
      '''
    SELECT * FROM ${DatabaseConfig.poolsTable} 
    WHERE ${DatabaseConfig.poolKey} = ?
  ''';

  static const String updatePoolCurrentDepth =
      '''
    UPDATE ${DatabaseConfig.poolsTable} 
    SET ${DatabaseConfig.poolCurrentDepth} = ?, 
        ${DatabaseConfig.poolUpdatedAt} = ? 
    WHERE ${DatabaseConfig.poolKey} = ?
  ''';

  static const String deletePoolByKey =
      '''
    DELETE FROM ${DatabaseConfig.poolsTable} 
    WHERE ${DatabaseConfig.poolKey} = ?
  ''';

  // History queries
  static const String getHistoryWithPool =
      '''
    SELECT h.*, p.${DatabaseConfig.poolName} as pool_name, p.${DatabaseConfig.poolKey} as pool_key
    FROM ${DatabaseConfig.historyTable} h
    JOIN ${DatabaseConfig.poolsTable} p ON h.${DatabaseConfig.historyPoolId} = p.${DatabaseConfig.poolId}
    ORDER BY h.${DatabaseConfig.historyTimestamp} DESC
  ''';

  static const String getHistoryByPoolKey =
      '''
    SELECT h.*, p.${DatabaseConfig.poolName} as pool_name, p.${DatabaseConfig.poolKey} as pool_key
    FROM ${DatabaseConfig.historyTable} h
    JOIN ${DatabaseConfig.poolsTable} p ON h.${DatabaseConfig.historyPoolId} = p.${DatabaseConfig.poolId}
    WHERE p.${DatabaseConfig.poolKey} = ?
    ORDER BY h.${DatabaseConfig.historyTimestamp} DESC
  ''';

  // Statistics queries
  static const String getPoolCount =
      '''
    SELECT COUNT(*) FROM ${DatabaseConfig.poolsTable}
  ''';

  static const String getHistoryCount =
      '''
    SELECT COUNT(*) FROM ${DatabaseConfig.historyTable}
  ''';
}
