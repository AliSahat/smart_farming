// lib/widgets/dashboard/water_monitor_widget.dart
// VERSI PERBAIKAN FINAL - Menampilkan min/max dalam CM
// ignore_for_file: deprecated_member_use, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:smart_farming/models/esp_water_data.dart';
import '../../models/pool_model.dart';

class WaterMonitorWidget extends StatelessWidget {
  final double waterLevel;
  final Pool pool;
  final ESPWaterData? latestWaterData;
  final bool isLoading;

  const WaterMonitorWidget({
    super.key,
    required this.waterLevel,
    required this.pool,
    this.latestWaterData,
    this.isLoading = false,
  });

  Color _getWaterLevelColor() {
    if (pool.isLevelTooLow) return Colors.orange;
    if (pool.isLevelTooHigh) return Colors.red;
    return Colors.blue;
  }

  String _getWaterStatus() => pool.levelStatus;

  IconData _getStatusIcon() {
    if (pool.isLevelTooLow) return Icons.arrow_downward_rounded;
    if (pool.isLevelTooHigh) return Icons.arrow_upward_rounded;
    if (!pool.hasReachedNormalLevel) return Icons.trending_up_rounded;
    return Icons.check_circle_outline;
  }

  String _getStatusDescription() {
    if (pool.isLevelTooLow) {
      return 'Di bawah batas minimum (${pool.minLevel.toStringAsFixed(1)}cm)';
    }
    if (pool.isLevelTooHigh) {
      return 'Di atas batas maksimum (${pool.maxLevel.toStringAsFixed(1)}cm)';
    }
    if (!pool.hasReachedNormalLevel) {
      return 'Di antara minimum dan normal, perlu diisi sampai (${pool.normalLevel.toStringAsFixed(1)}cm)';
    }
    return 'Kondisi air dalam batas aman';
  }

  @override
  Widget build(BuildContext context) {
    final remainingSpace =
        latestWaterData?.distanceToWater ?? (pool.depth - pool.currentDepth);

    return Card(
      elevation: 6.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getWaterLevelColor().withOpacity(0.05),
              _getWaterLevelColor().withOpacity(0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMainContent(remainingSpace),
            const SizedBox(height: 20),
            _buildStatusIndicatorsCompact(), // Panggil fungsi yang sudah diperbaiki
          ],
        ),
      ),
    );
  }

  // (Sisa fungsi buildHeader, buildMainContent, dll. tidak perlu diubah, bisa dibiarkan)
  // ...

  // **FUNGSI YANG DIPERBAIKI**
  // Memastikan kartu ini menampilkan nilai min/max dari model secara langsung
  Widget _buildStatusIndicatorsCompact() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItemCompact(
            icon: Icons.arrow_downward_rounded,
            color: Colors.orange,
            title: 'Minimum',
            value:
                '${pool.minLevel.toStringAsFixed(1)} cm', // Ambil langsung dari model
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatusItemCompact(
            icon: Icons.check_circle_rounded,
            color: Colors.blue,
            title: 'Normal',
            value: '${pool.normalLevel.toStringAsFixed(1)} cm',
          ),
          Container(width: 1, height: 40, color: Colors.grey[200]),
          _buildStatusItemCompact(
            icon: Icons.arrow_upward_rounded,
            color: Colors.red,
            title: 'Maksimum',
            value:
                '${pool.maxLevel.toStringAsFixed(1)} cm', // Ambil langsung dari model
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getWaterLevelColor().withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(_getStatusIcon(), color: _getWaterLevelColor(), size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monitor Ketinggian Air',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Status: ${_getWaterStatus()}',
                style: TextStyle(
                  fontSize: 14,
                  color: _getWaterLevelColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getStatusDescription(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        if (isLoading)
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(left: 12),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: _getWaterLevelColor(),
            ),
          ),
      ],
    );
  }

  Widget _buildMainContent(double remainingSpace) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildCircularIndicatorCompact(),
              const SizedBox(height: 20),
              _buildDetailInfoHorizontal(remainingSpace),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCircularIndicator(size: 180),
              const SizedBox(width: 24),
              Expanded(child: _buildDetailInfoHorizontal(remainingSpace)),
            ],
          );
        }
      },
    );
  }

  Widget _buildCircularIndicatorCompact() {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: _getWaterLevelColor().withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              value: waterLevel / 100,
              strokeWidth: 12,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_getWaterLevelColor()),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${waterLevel.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Level Air',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularIndicator({double size = 200}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: _getWaterLevelColor().withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          SizedBox(
            width: size - 40,
            height: size - 40,
            child: CircularProgressIndicator(
              value: waterLevel / 100,
              strokeWidth: 14,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_getWaterLevelColor()),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${waterLevel.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
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
    );
  }

  Widget _buildDetailInfoHorizontal(double remainingSpace) {
    return Column(
      children: [
        _buildDetailInfoCard(
          title: 'Ketinggian Saat Ini',
          value: '${pool.currentDepth.toStringAsFixed(1)} cm',
          icon: Icons.waves_rounded,
          color: _getWaterLevelColor(),
        ),
        const SizedBox(height: 12),
        _buildDetailInfoCard(
          title: 'Kedalaman Total',
          value: '${pool.depth} cm',
          icon: Icons.straighten_rounded,
          color: Colors.indigo,
        ),
        const SizedBox(height: 12),
        _buildDetailInfoCard(
          title: 'Jarak Sensor ke Air',
          value: '${remainingSpace.toStringAsFixed(1)} cm',
          icon: Icons.height_rounded,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildDetailInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItemCompact({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
