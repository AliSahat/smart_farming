class HistoryEntry {
  final int? id;
  final String poolKey;
  final String poolName;
  final String event;
  final String eventType;
  final double waterLevel;
  final String details;
  final DateTime timestamp;

  HistoryEntry({
    this.id,
    required this.poolKey,
    required this.poolName,
    required this.event,
    required this.eventType,
    required this.waterLevel,
    required this.details,
    required this.timestamp,
  });

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      id: map['id'],
      poolKey: map['pool_key'],
      poolName: map['pool_name'],
      event: map['event'],
      eventType: map['event_type'],
      waterLevel: map['water_level'].toDouble(),
      details: map['details'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pool_key': poolKey,
      'pool_name': poolName,
      'event': event,
      'event_type': eventType,
      'water_level': waterLevel,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
