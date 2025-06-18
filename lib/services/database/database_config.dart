class DatabaseConfig {
  static const String databaseName = 'smart_farming.db';
  static const int databaseVersion = 1;

  // Table names
  static const String poolsTable = 'pools';
  static const String historyTable = 'history';

  // Pool table columns
  static const String poolId = 'id';
  static const String poolKey = 'key';
  static const String poolName = 'name';
  static const String poolDepth = 'depth';
  static const String poolNormalLevel = 'normal_level';
  static const String poolMaxLevel = 'max_level';
  static const String poolMinLevel = 'min_level';
  static const String poolCurrentDepth = 'current_depth';
  static const String poolCreatedAt = 'created_at';
  static const String poolUpdatedAt = 'updated_at';

  // History table columns
  static const String historyId = 'id';
  static const String historyPoolId = 'pool_id';
  static const String historyEvent = 'event';
  static const String historyEventType = 'event_type';
  static const String historyWaterLevel = 'water_level';
  static const String historyDetails = 'details';
  static const String historyTimestamp = 'timestamp';
}
