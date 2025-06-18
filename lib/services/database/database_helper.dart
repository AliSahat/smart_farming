import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../../models/pool_model.dart';
import '../../models/history_model.dart';
import 'database_config.dart';
import 'sql_queries.dart';
import 'database_exception.dart';
import 'repositories/pool_repository.dart';
import 'repositories/history_repository.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  // Repositories
  late final PoolRepository _poolRepository;
  late final HistoryRepository _historyRepository;

  DatabaseHelper._internal();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  // Factory constructor
  factory DatabaseHelper() => instance;

  // Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    try {
      final String path = join(
        await getDatabasesPath(),
        DatabaseConfig.databaseName,
      );

      debugPrint('Initializing database at: $path');

      final database = await openDatabase(
        path,
        version: DatabaseConfig.databaseVersion,
        onCreate: _onCreate,
        onOpen: _onOpen,
        onUpgrade: _onUpgrade,
      );

      // Initialize repositories
      _poolRepository = PoolRepository(database);
      _historyRepository = HistoryRepository(database);

      return database;
    } catch (e) {
      debugPrint('Database initialization failed: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Create tables - TANPA insert default pools
  Future<void> _onCreate(Database db, int version) async {
    try {
      debugPrint('Creating database tables...');

      await db.execute(SqlQueries.createPoolsTable);
      await db.execute(SqlQueries.createHistoryTable);

      debugPrint('Database tables created successfully');
      debugPrint('Database initialized with empty tables');
    } catch (e) {
      debugPrint('Error creating database: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  // Database opened - TANPA check default pools
  Future<void> _onOpen(Database db) async {
    try {
      debugPrint('Database opened successfully');
      final poolCount = await _getPoolCount(db);
      debugPrint('Current pools in database: $poolCount');
    } catch (e) {
      debugPrint('Error on database open: $e');
    }
  }

  // Database upgrade
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Database upgrade from $oldVersion to $newVersion');
    // Handle future database migrations here
  }

  // Helper method to get pool count
  Future<int> _getPoolCount(Database db) async {
    try {
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseConfig.poolsTable}',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Error getting pool count: $e');
      return 0;
    }
  }

  // Pool Repository Methods
  Future<Map<String, Pool>> getAllPools() => _poolRepository.getAllPools();

  Future<Pool?> getPoolByKey(String key) => _poolRepository.getPoolByKey(key);

  Future<int> insertPool(String key, Pool pool) =>
      _poolRepository.insertPool(key: key, pool: pool);

  Future<int> updatePool(String key, Pool pool) =>
      _poolRepository.updatePool(key: key, pool: pool);

  Future<int> updatePoolCurrentDepth(String key, double currentDepth) =>
      _poolRepository.updateCurrentDepth(key: key, currentDepth: currentDepth);

  Future<int> deletePool(String key) => _poolRepository.deletePool(key);

  // History Repository Methods
  Future<int> insertHistory({
    required String poolKey,
    required String event,
    required String eventType,
    required double waterLevel,
    required String details,
  }) => _historyRepository.insertHistory(
    poolKey: poolKey,
    event: event,
    eventType: eventType,
    waterLevel: waterLevel,
    details: details,
  );

  Future<List<HistoryEntry>> getAllHistory() =>
      _historyRepository.getAllHistory();

  Future<List<HistoryEntry>> getHistoryByPoolKey(String poolKey) =>
      _historyRepository.getHistoryByPoolKey(poolKey);

  Future<List<HistoryEntry>> getHistory({
    String? poolKey,
    DateTime? startDate,
    DateTime? endDate,
  }) => _historyRepository.getHistoryWithFilters(
    poolKey: poolKey,
    startDate: startDate,
    endDate: endDate,
  );

  // Database utilities
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final poolCount = await _poolRepository.getPoolCount();
      final historyCount = await _historyRepository.getHistoryCount();
      final db = await database;

      return {
        'poolCount': poolCount,
        'historyCount': historyCount,
        'databasePath': db.path,
        'version': DatabaseConfig.databaseVersion,
      };
    } catch (e) {
      debugPrint('Error getting database info: $e');
      return {
        'poolCount': 0,
        'historyCount': 0,
        'databasePath': 'unknown',
        'version': 0,
      };
    }
  }

  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete(DatabaseConfig.historyTable);
      await db.delete(DatabaseConfig.poolsTable);
      debugPrint('All data cleared from database');
    } catch (e) {
      debugPrint('Error clearing data: $e');
      throw DatabaseExceptionHandler.handle(e);
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      debugPrint('Database closed');
    }
  }
}
