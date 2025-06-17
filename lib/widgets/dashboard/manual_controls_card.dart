import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManualControlsCard extends StatefulWidget {
  final Function(String, String) addNotification;

  const ManualControlsCard({super.key, required this.addNotification});

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
                    widget.addNotification(
                      'Mode ${value ? 'Manual' : 'Otomatis'} diaktifkan',
                      'info',
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
              _buildControlButton(
                icon: Icons.water_drop,
                label: 'Buka Kran Air',
                color: Colors.green,
                onPressed: () {
                  widget.addNotification(
                    'Kran air dibuka secara manual pada ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                    'info',
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildControlButton(
                icon: Icons.stop,
                label: 'Tutup Kran Air',
                color: Colors.red,
                onPressed: () {
                  widget.addNotification(
                    'Kran air ditutup secara manual pada ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                    'info',
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildControlButton(
                icon: Icons.flash_on,
                label: 'Buka Pembuangan',
                color: Colors.orange,
                onPressed: () {
                  widget.addNotification(
                    'Kran pembuangan dibuka secara manual pada ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                    'warning',
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildControlButton(
                icon: Icons.refresh,
                label: 'Reset Sistem',
                color: Colors.purple,
                onPressed: () {
                  widget.addNotification(
                    'Sistem direset pada ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                    'info',
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
