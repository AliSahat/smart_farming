// lib/widgets/dashboard/water_monitor_widget.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../models/pool_model.dart';

class WaterMonitorWidget extends StatelessWidget {
  final double waterLevel;
  final Pool pool;

  const WaterMonitorWidget({
    super.key,
    required this.waterLevel,
    required this.pool,
  });

  // Fungsi untuk menentukan warna progress bar berdasarkan level air
  Color _getWaterLevelColor() {
    final currentDepthCm = (waterLevel / 100) * pool.depth;
    if (currentDepthCm < 30) return Colors.orange;
    if (currentDepthCm > pool.normalLevel) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[50]!.withOpacity(0.1),
              Colors.green[50]!.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monitor Ketinggian Air',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Custom Water Level Indicator - Ganti SleekCircularSlider
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Circle
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getWaterLevelColor().withOpacity(0.1),
                          border: Border.all(
                            color: _getWaterLevelColor().withOpacity(0.3),
                            width: 8,
                          ),
                        ),
                      ),
                      // Progress Circle
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: waterLevel / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getWaterLevelColor(),
                          ),
                        ),
                      ),
                      // Center Text
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${waterLevel.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const Text(
                            'Level Air',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Kolom untuk informasi detail di sebelah kanan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailInfo(
                        title: 'Ketinggian Saat Ini',
                        value: '${pool.currentDepth.toStringAsFixed(1)} cm',
                        icon: Icons.waves,
                        color: _getWaterLevelColor(),
                      ),
                      const Divider(height: 24),
                      _buildDetailInfo(
                        title: 'Kedalaman Total',
                        value: '${pool.depth} cm',
                        icon: Icons.straighten,
                        color: Colors.grey,
                      ),
                      const Divider(height: 24),
                      _buildDetailInfo(
                        title: 'Sisa Ruang',
                        value:
                            '${(pool.depth - pool.currentDepth).toStringAsFixed(1)} cm',
                        icon: Icons.arrow_downward,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Indikator Batas Aman dan Minimum
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Normal: ${pool.normalLevel} cm',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Min: 30 cm',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membuat baris informasi detail
  Widget _buildDetailInfo({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
