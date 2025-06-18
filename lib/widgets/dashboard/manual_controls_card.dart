// ignore_for_file: unused_element, unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManualControlsCard extends StatefulWidget {
  final String valveStatus;
  final String drainStatus;
  final Function(String) onValveStatusChanged;
  final Function(String) onDrainStatusChanged;

  const ManualControlsCard({
    super.key,
    required this.valveStatus,
    required this.drainStatus,
    required this.onValveStatusChanged,
    required this.onDrainStatusChanged,
  });

  @override
  State<ManualControlsCard> createState() => _ManualControlsCardState();
}

class _ManualControlsCardState extends State<ManualControlsCard> {
  bool _manualMode = false;

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
                const Icon(Icons.settings, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Kontrol Manual',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Switch(
                  value: _manualMode,
                  onChanged: (value) {
                    setState(() {
                      _manualMode = value;
                    });
                    _showSuccessSnackBar(
                      'Mode ${value ? 'Manual' : 'Otomatis'} diaktifkan',
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_manualMode)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Sistem dalam mode otomatis',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                ),
              ),
            if (_manualMode) ...[
              _buildControlToggle(
                icon: Icons.water_drop,
                label: 'Kran Utama',
                status: widget.valveStatus,
                onChanged: widget.onValveStatusChanged,
                openColor: Colors.green,
                closedColor: Colors.red,
              ),
              const SizedBox(height: 12),
              _buildControlToggle(
                icon: Icons.flash_on,
                label: 'Kran Pembuangan',
                status: widget.drainStatus,
                onChanged: widget.onDrainStatusChanged,
                openColor: Colors.orange,
                closedColor: Colors.green,
              ),
              const SizedBox(height: 16),
              _buildResetButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlToggle({
    required IconData icon,
    required String label,
    required String status,
    required Function(String) onChanged,
    required Color openColor,
    required Color closedColor,
  }) {
    final isOpen = status == 'open';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isOpen ? openColor : closedColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isOpen ? openColor : closedColor).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isOpen ? openColor : closedColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  isOpen ? 'TERBUKA' : 'TERTUTUP',
                  style: TextStyle(
                    color: isOpen ? openColor : closedColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isOpen,
            onChanged: (value) {
              final newStatus = value ? 'open' : 'closed';
              onChanged(newStatus);

              _showSuccessSnackBar(
                '$label ${value ? 'dibuka' : 'ditutup'} secara manual',
              );
            },
            activeColor: openColor,
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Reset kedua valve ke closed
          widget.onValveStatusChanged('closed');
          widget.onDrainStatusChanged('closed');

          _showSuccessSnackBar('Sistem direset - Semua kran ditutup');
        },
        icon: const Icon(Icons.refresh, size: 18),
        label: const Text('Reset Sistem'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
