import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database/database_helper.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String? _databasePath;
  Map<String, dynamic>? _dbInfo;

  @override
  void initState() {
    super.initState();
    _loadDatabaseInfo();
  }

  Future<void> _loadDatabaseInfo() async {
    try {
      final dbHelper = DatabaseHelper();
      final db = await dbHelper.database;
      final info = await dbHelper.getDatabaseInfo();

      setState(() {
        _databasePath = db.path;
        _dbInfo = info;
      });
    } catch (e) {
      print('Error loading database info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Database Path Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.folder, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Database Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_databasePath != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: SelectableText(
                          _databasePath!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _databasePath!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Path copied to clipboard'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 16),
                            label: const Text('Copy Path'),
                          ),
                        ],
                      ),
                    ] else ...[
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Database Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.green),
                        const SizedBox(width: 8),
                        const Text(
                          'Database Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_dbInfo != null) ...[
                      _buildInfoRow('Pool Count', '${_dbInfo!['poolCount']}'),
                      _buildInfoRow(
                        'History Count',
                        '${_dbInfo!['historyCount']}',
                      ),
                      _buildInfoRow(
                        'Database Version',
                        '${_dbInfo!['version']}',
                      ),
                    ] else ...[
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Instructions Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'How to Access Database',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Copy the database path above\n'
                      '2. Use Android Studio Device File Explorer\n'
                      '3. Or use ADB commands:\n'
                      '   adb shell\n'
                      '   cd /data/data/com.example.smart_farming/databases/\n'
                      '   ls -la\n\n'
                      '4. Pull database file:\n'
                      '   adb pull /data/data/com.example.smart_farming/databases/smart_farming.db\n\n'
                      '5. Open with SQLite Browser or similar tool',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
