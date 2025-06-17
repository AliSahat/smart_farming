// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class SensorDataCard extends StatelessWidget {
  final double waterLevel;
  final bool isConnected;
  final String poolName;

  const SensorDataCard({
    super.key,
    required this.waterLevel,
    required this.isConnected,
    required this.poolName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.blue[50]!.withOpacity(0.3),
              Colors.indigo[50]!.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.sensors, color: Colors.blue[600], size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Data Sensor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isConnected ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isConnected ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isConnected
                              ? Colors.green[700]
                              : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Data Items
            _buildDataItem(
              icon: Icons.pool,
              label: 'Kolam/Wadah',
              value: poolName,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildDataItem(
              icon: Icons.water_drop,
              label: 'Level Air',
              value: '${waterLevel.toStringAsFixed(1)}%',
              color: _getWaterLevelColor(),
            ),
            const SizedBox(height: 12),
            _buildDataItem(
              icon: Icons.thermostat,
              label: 'Suhu Air',
              value: '26.5°C',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildDataItem(
              icon: Icons.schedule,
              label: 'Update Terakhir',
              value: DateTime.now().toString().substring(11, 19),
              color: Colors.grey,
            ),

            const SizedBox(height: 16),

            // Quick Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickStat('Hari Ini', '45', 'Pembacaan'),
                  Container(height: 30, width: 1, color: Colors.grey[300]),
                  _buildQuickStat('Minggu Ini', '312', 'Pembacaan'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String period, String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[600],
          ),
        ),
        Text(period, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[500])),
      ],
    );
  }

  Color _getWaterLevelColor() {
    if (waterLevel < 30) return Colors.red;
    if (waterLevel > 80) return Colors.orange;
    return Colors.green;
  }
}
