// lib/widgets/dashboard/control_status_card.dart
// VERSI PERBAIKAN FINAL - FIX TYPE ERROR
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../models/notification_model.dart'; // Import ini penting

class ControlStatusCard extends StatelessWidget {
  // FIX: Menggunakan tipe data enum
  final ValveStatus valveStatus;
  final DrainStatus drainStatus;
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
              icon: Icons.water_drop,
              label: 'Kran Utama',
              status: _getValveStatusText(valveStatus), // Konversi enum ke teks
              color: _getValveStatusColor(valveStatus),
            ),
            const SizedBox(height: 12),
            _buildControlItem(
              icon: Icons.output_rounded,
              label: 'Kran Pembuangan',
              status: _getDrainStatusText(drainStatus), // Konversi enum ke teks
              color: _getDrainStatusColor(drainStatus),
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
                    color: color.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: color,
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

  // --- Fungsi Helper untuk konversi Enum ke Tampilan ---

  String _getValveStatusText(ValveStatus status) {
    switch (status) {
      case ValveStatus.open:
        return 'TERBUKA';
      case ValveStatus.closed:
        return 'TERTUTUP';
      case ValveStatus.auto:
        return 'OTOMATIS';
    }
  }

  String _getDrainStatusText(DrainStatus status) {
    switch (status) {
      case DrainStatus.open:
        return 'TERBUKA';
      case DrainStatus.closed:
        return 'TERTUTUP';
    }
  }

  Color _getValveStatusColor(ValveStatus status) {
    switch (status) {
      case ValveStatus.open:
        return Colors.green;
      case ValveStatus.closed:
        return Colors.red;
      case ValveStatus.auto:
        return Colors.blue;
    }
  }

  Color _getDrainStatusColor(DrainStatus status) {
    switch (status) {
      case DrainStatus.open:
        return Colors.orange;
      case DrainStatus.closed:
        return Colors.blueGrey;
    }
  }
}
