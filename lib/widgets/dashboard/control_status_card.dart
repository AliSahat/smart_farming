// lib/widgets/dashboard/control_status_card.dart
// VERSI PERBAIKAN FINAL - FIX TYPE ERROR
// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import '../../models/notification_model.dart'; // Import ini penting

class ControlStatusCard extends StatelessWidget {
  // FIX: Menggunakan tipe data enum
  final ValveStatus valveStatus;
  final DrainStatus drainStatus;
  final double normalLevel;
  final String? waterLevelStatus; // Status level air saat ini
  final bool isManualMode; // Apakah dalam mode manual

  const ControlStatusCard({
    super.key,
    required this.valveStatus,
    required this.drainStatus,
    required this.normalLevel,
    this.waterLevelStatus,
    this.isManualMode = false,
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
            Row(
              children: [
                const Text(
                  'Status Kontrol',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isManualMode
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isManualMode ? Colors.orange : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isManualMode ? Icons.pan_tool : Icons.auto_awesome,
                        size: 14,
                        color: isManualMode ? Colors.orange : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isManualMode ? 'Manual' : 'Otomatis',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isManualMode ? Colors.orange : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (waterLevelStatus != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.water, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          waterLevelStatus!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildControlItem(
              icon: Icons.water_drop,
              label: 'Kran Utama',
              status: _getValveStatusText(valveStatus), // Konversi enum ke teks
              color: _getValveStatusColor(valveStatus),
              description: _getValveDescription(valveStatus),
            ),
            const SizedBox(height: 12),
            _buildControlItem(
              icon: Icons.output_rounded,
              label: 'Kran Pembuangan',
              status: _getDrainStatusText(drainStatus), // Konversi enum ke teks
              color: _getDrainStatusColor(drainStatus),
              description: _getDrainDescription(drainStatus),
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
    String? description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
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
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      description,
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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

  String _getValveDescription(ValveStatus status) {
    switch (status) {
      case ValveStatus.open:
        return 'Mengisi air ke dalam kolam sampai level normal (${normalLevel.toStringAsFixed(1)}cm)';
      case ValveStatus.closed:
        return 'Pengisian air dihentikan karena level sudah mencapai normal';
      case ValveStatus.auto:
        return 'Dikendalikan otomatis sesuai level air';
    }
  }

  String _getDrainDescription(DrainStatus status) {
    switch (status) {
      case DrainStatus.open:
        return 'Mengurangi level air karena melebihi batas maksimum';
      case DrainStatus.closed:
        return 'Pembuangan ditutup karena level air tidak melebihi maksimum';
    }
  }
}
