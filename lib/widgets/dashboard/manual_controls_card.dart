// lib/widgets/dashboard/manual_controls_card.dart
// VERSI PERBAIKAN - Menggunakan Tombol, bukan switch
import 'package:flutter/material.dart';
import '../../models/notification_model.dart';

class ManualControlsCard extends StatelessWidget {
  final bool isManualMode;
  final ValveStatus valveStatus;
  final DrainStatus drainStatus;
  final Function(bool) onManualModeChanged;
  final Function(ValveStatus) onValveChanged;
  final Function(DrainStatus) onDrainChanged;

  const ManualControlsCard({
    super.key,
    required this.isManualMode,
    required this.valveStatus,
    required this.drainStatus,
    required this.onManualModeChanged,
    required this.onValveChanged,
    required this.onDrainChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      color: isManualMode ? Colors.amber[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isManualMode ? Colors.amber.shade400 : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pan_tool_rounded, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Kontrol Manual',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: isManualMode,
                  onChanged: onManualModeChanged,
                  activeColor: Colors.amber[700],
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstChild: _buildAutoModeIndicator(),
              secondChild: _buildManualControls(),
              crossFadeState: isManualMode
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoModeIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sistem dalam mode otomatis. Aktifkan switch untuk kontrol manual.',
              style: TextStyle(color: Colors.blue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualControls() {
    return Column(
      children: [
        _buildControlRow(
          label: "Kran Utama",
          icon: Icons.water_drop,
          isOpen: valveStatus == ValveStatus.open,
          onOpen: () => onValveChanged(ValveStatus.open),
          onClose: () => onValveChanged(ValveStatus.closed),
        ),
        const SizedBox(height: 12),
        _buildControlRow(
          label: "Pembuangan",
          icon: Icons.output_rounded,
          isOpen: drainStatus == DrainStatus.open,
          onOpen: () => onDrainChanged(DrainStatus.open),
          onClose: () => onDrainChanged(DrainStatus.closed),
        ),
      ],
    );
  }

  Widget _buildControlRow({
    required String label,
    required IconData icon,
    required bool isOpen,
    required VoidCallback onOpen,
    required VoidCallback onClose,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          // Tombol Buka
          ElevatedButton(
            onPressed: onOpen,
            style: ElevatedButton.styleFrom(
              foregroundColor: isOpen ? Colors.white : Colors.green.shade800,
              backgroundColor: isOpen
                  ? Colors.green.shade400
                  : Colors.green.shade50,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              elevation: isOpen ? 2 : 0,
            ),
            child: const Text('Buka'),
          ),

          // Tombol Tutup
          ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              foregroundColor: !isOpen ? Colors.white : Colors.red.shade800,
              backgroundColor: !isOpen
                  ? Colors.red.shade400
                  : Colors.red.shade50,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              elevation: !isOpen ? 2 : 0,
            ),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
