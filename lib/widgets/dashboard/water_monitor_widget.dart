// lib/widgets/dashboard/water_monitor_widget.dart

// ignore_for_file: deprecated_member_use, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:smart_farming/models/esp_water_data.dart';
import '../../models/pool_model.dart';

/// Widget untuk memantau tinggi air kolam dengan tampilan yang modern dan responsif
///
/// Widget ini menampilkan:
/// - Level air dalam bentuk circular progress indicator
/// - Status kondisi air (Normal/Rendah/Berlebih)
/// - Informasi detail ketinggian, kedalaman, dan sisa ruang
/// - Indikator batas aman dan minimum
class WaterMonitorWidget extends StatelessWidget {
  /// Level air dalam persen (0-100)
  /// Dihitung berdasarkan: (currentDepth / totalDepth) * 100
  final double waterLevel;

  /// Model data kolam yang berisi informasi kedalaman dan batas normal
  final Pool pool;

  /// Data terbaru dari sensor ESP32 (optional)
  /// Berisi informasi jarak sensor ke permukaan air dan timestamp
  final ESPWaterData? latestWaterData;

  /// Status loading untuk menampilkan indikator saat data sedang diambil
  final bool isLoading;

  const WaterMonitorWidget({
    super.key,
    required this.waterLevel,
    required this.pool,
    this.latestWaterData,
    this.isLoading = false,
  });

  /// Menentukan warna progress indicator berdasarkan kondisi air
  Color _getWaterLevelColor() {
    if (pool.currentDepth < 30) {
      return Colors.orange; // Air terlalu rendah
    }
    if (pool.currentDepth > pool.normalLevel) {
      return Colors.red; // Air berlebih
    }
    return Colors.blue; // Kondisi normal
  }

  /// Mendapatkan status kondisi air dalam bentuk text
  String _getWaterStatus() {
    if (pool.currentDepth < 30) return 'Rendah';
    if (pool.currentDepth > pool.normalLevel) return 'Berlebih';
    return 'Normal';
  }

  /// Mendapatkan ikon yang sesuai dengan status air
  IconData _getStatusIcon() {
    if (pool.currentDepth < 30) return Icons.water_drop_outlined;
    if (pool.currentDepth > pool.normalLevel) return Icons.warning_rounded;
    return Icons.check_circle_outline;
  }

  /// Mendapatkan pesan deskripsi berdasarkan status air
  String _getStatusDescription() {
    if (pool.currentDepth < 30) {
      return 'Air terlalu rendah, perlu penambahan';
    }
    if (pool.currentDepth > pool.normalLevel) {
      return 'Air berlebih, perlu pembuangan';
    }
    return 'Kondisi air dalam batas normal';
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
            colors: [Colors.blue.shade50, Colors.indigo.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan status dan loading indicator
            _buildHeader(),

            const SizedBox(height: 24),

            // Konten utama dengan layout responsif
            _buildMainContent(remainingSpace),

            const SizedBox(height: 20),

            // Status indicators saja
            _buildStatusIndicatorsCompact(),
          ],
        ),
      ),
    );
  }

  /// Membangun header dengan status dan loading indicator
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

  /// Membangun konten utama dengan layout responsif
  Widget _buildMainContent(double remainingSpace) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Untuk layar kecil, gunakan layout vertikal
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              _buildCircularIndicatorCompact(),
              const SizedBox(height: 20),
              _buildDetailInfoHorizontal(remainingSpace),
            ],
          );
        } else {
          // Untuk layar lebar, gunakan layout horizontal
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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

  /// Circular indicator compact untuk mobile
  Widget _buildCircularIndicatorCompact() {
    return Container(
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
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getWaterLevelColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getWaterLevelColor().withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getWaterStatus(),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getWaterLevelColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Circular indicator untuk desktop
  Widget _buildCircularIndicator({double size = 200}) {
    return Container(
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

          Container(
            width: size - 10,
            height: size - 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getWaterLevelColor().withOpacity(0.2),
                width: 2,
              ),
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
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getWaterLevelColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getWaterLevelColor().withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getWaterStatus(),
                  style: TextStyle(
                    fontSize: 11,
                    color: _getWaterLevelColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section informasi detail dengan layout horizontal yang optimal
  Widget _buildDetailInfoHorizontal(double remainingSpace) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Untuk layar sangat kecil
        if (constraints.maxWidth < 280) {
          return _buildDetailInfoVertical(remainingSpace);
        }
        // Untuk layar medium, gunakan 2 kolom
        else if (constraints.maxWidth < 480) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDetailInfoCard(
                      title: 'Ketinggian',
                      value: '${pool.currentDepth.toStringAsFixed(1)} cm',
                      subtitle: 'Saat ini',
                      icon: Icons.waves_rounded,
                      color: _getWaterLevelColor(),
                      isCompact: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailInfoCard(
                      title: 'Total',
                      value: '${pool.depth} cm',
                      subtitle: 'Kedalaman',
                      icon: Icons.straighten_rounded,
                      color: Colors.indigo,
                      isCompact: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailInfoCard(
                title: 'Jarak Sensor ke Permukaan Air',
                value: '${remainingSpace.toStringAsFixed(1)} cm',
                subtitle: 'Data real-time dari ESP32',
                icon: Icons.height_rounded,
                color: Colors.teal,
                isCompact: false,
              ),
            ],
          );
        }
        // Untuk layar lebar, gunakan 3 kolom
        else {
          return Row(
            children: [
              Expanded(
                child: _buildDetailInfoCard(
                  title: 'Ketinggian Saat Ini',
                  value: '${pool.currentDepth.toStringAsFixed(1)} cm',
                  subtitle: 'Dari dasar kolam',
                  icon: Icons.waves_rounded,
                  color: _getWaterLevelColor(),
                  isCompact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailInfoCard(
                  title: 'Kedalaman Total',
                  value: '${pool.depth} cm',
                  subtitle: 'Kapasitas maksimum',
                  icon: Icons.straighten_rounded,
                  color: Colors.indigo,
                  isCompact: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailInfoCard(
                  title: 'Jarak Sensor',
                  value: '${remainingSpace.toStringAsFixed(1)} cm',
                  subtitle: 'Ke permukaan air',
                  icon: Icons.height_rounded,
                  color: Colors.teal,
                  isCompact: true,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  /// Fallback vertical layout untuk layar sangat kecil
  Widget _buildDetailInfoVertical(double remainingSpace) {
    return Column(
      children: [
        _buildDetailInfoCard(
          title: 'Ketinggian Saat Ini',
          value: '${pool.currentDepth.toStringAsFixed(1)} cm',
          subtitle: 'Dari dasar kolam',
          icon: Icons.waves_rounded,
          color: _getWaterLevelColor(),
          isCompact: true,
        ),
        const SizedBox(height: 8),
        _buildDetailInfoCard(
          title: 'Kedalaman Total',
          value: '${pool.depth} cm',
          subtitle: 'Kapasitas maksimum',
          icon: Icons.straighten_rounded,
          color: Colors.indigo,
          isCompact: true,
        ),
        const SizedBox(height: 8),
        _buildDetailInfoCard(
          title: 'Jarak Sensor',
          value: '${remainingSpace.toStringAsFixed(1)} cm',
          subtitle: 'Ke permukaan air',
          icon: Icons.height_rounded,
          color: Colors.teal,
          isCompact: true,
        ),
      ],
    );
  }

  /// Card informasi detail yang optimized
  Widget _buildDetailInfoCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: isCompact ? 32 : 40,
            height: isCompact ? 32 : 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: isCompact ? 16 : 20),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF1F2937),
                    fontSize: isCompact ? 11 : 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: isCompact ? 16 : 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isCompact ? 9 : 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Status indicators yang lebih compact
  Widget _buildStatusIndicatorsCompact() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatusItemCompact(
              icon: Icons.check_circle_rounded,
              color: Colors.green,
              title: 'Normal',
              value: '${pool.normalLevel} cm',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatusItemCompact(
              icon: Icons.warning_amber_rounded,
              color: Colors.orange,
              title: 'Minimum',
              value:
                  '${((pool.minLevel / 100) * pool.depth).toStringAsFixed(0)} cm',
            ),
          ),
        ],
      ),
    );
  }

  /// Item status yang compact
  Widget _buildStatusItemCompact({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: color,
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
