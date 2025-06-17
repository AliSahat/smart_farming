// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ControlStatusCard extends StatelessWidget {
  final String valveStatus;
  final String drainStatus;
  final double normalLevel;

  const ControlStatusCard({
    super.key,
    required this.valveStatus,
    required this.drainStatus,
    required this.normalLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status Kontrol',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildControlItem(
              icon: Icons.speed,
              label: 'Kran Utama',
              status: _getValveStatusText(valveStatus),
              color: _getValveStatusColor(valveStatus),
            ),
            const SizedBox(height: 12),
            _buildControlItem(
              icon: Icons.flash_on,
              label: 'Kran Pembuangan',
              status: _getDrainStatusText(drainStatus),
              color: _getDrainStatusColor(drainStatus),
            ),
            const SizedBox(height: 12),
            _buildControlItem(
              icon: Icons.track_changes,
              label: 'Level Normal',
              status: '${normalLevel.toStringAsFixed(1)} cm',
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlItem({
    required IconData icon,
    required String label,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: _getDarkerColor(color),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: _getVeryDarkColor(color),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method untuk mendapatkan warna yang lebih gelap (pengganti shade[700])
  Color _getDarkerColor(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withLightness((hsl.lightness * 0.6).clamp(0.0, 1.0)).toColor();
  }

  // Helper method untuk mendapatkan warna yang sangat gelap (pengganti shade[900])
  Color _getVeryDarkColor(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withLightness((hsl.lightness * 0.3).clamp(0.0, 1.0)).toColor();
  }

  String _getValveStatusText(String status) {
    switch (status) {
      case 'open':
        return 'TERBUKA';
      case 'closed':
        return 'TERTUTUP';
      case 'auto':
        return 'OTOMATIS';
      default:
        return 'TIDAK DIKETAHUI';
    }
  }

  String _getDrainStatusText(String status) {
    switch (status) {
      case 'open':
        return 'TERBUKA';
      case 'closed':
        return 'TERTUTUP';
      default:
        return 'TIDAK DIKETAHUI';
    }
  }

  Color _getValveStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'auto':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getDrainStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.orange;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
