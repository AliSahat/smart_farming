class HistoryItem {
  final String id;
  final DateTime timestamp;
  final String poolName;
  final String event;
  final String eventType;
  final double waterLevel;
  final String details;

  HistoryItem({
    required this.id,
    required this.timestamp,
    required this.poolName,
    required this.event,
    required this.eventType,
    required this.waterLevel,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'poolName': poolName,
      'event': event,
      'eventType': eventType,
      'waterLevel': waterLevel,
      'details': details,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      poolName: json['poolName'],
      event: json['event'],
      eventType: json['eventType'],
      waterLevel: json['waterLevel'].toDouble(),
      details: json['details'],
    );
  }

  @override
  String toString() {
    return 'HistoryItem(id: $id, event: $event, poolName: $poolName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
