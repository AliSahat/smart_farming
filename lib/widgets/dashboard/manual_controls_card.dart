// ignore_for_file: unused_element, unused_import, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../screens/service_layer/manual_control_service.dart';
import '../../helper/notification_service.dart';
import '../../providers/notification_provider.dart';

class ManualControlCard extends StatefulWidget {
  final bool isAutoModeEnabled;
  final String? poolName;
  final Function(bool)? onAutoModeChanged;

  const ManualControlCard({
    super.key,
    required this.isAutoModeEnabled,
    required this.poolName,
    this.onAutoModeChanged,
  });

  @override
  State<ManualControlCard> createState() => _ManualControlCardState();
}

class _ManualControlCardState extends State<ManualControlCard> {
  late final ManualControlService _controlService;
  late bool _isManualMode;

  // Manual control states - hapus pompa dan valve
  bool _isFillModeActive = false;
  bool _isDrainModeActive = false;

  @override
  void initState() {
    super.initState();
    _isManualMode = !widget.isAutoModeEnabled;

    // Fix: Ambil NotificationProvider dari context
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    _controlService = ManualControlService(
      NotificationService(notificationProvider),
    );

    Logger().i("🏁 Manual controls initialized for pool: ${widget.poolName}");
  }

  void _toggleMode() {
    setState(() {
      _isManualMode = !_isManualMode;
      if (!_isManualMode) {
        // Reset semua kontrol saat kembali ke auto
        _isFillModeActive = false;
        _isDrainModeActive = false;
      }
    });

    // Callback ke parent
    if (widget.onAutoModeChanged != null) {
      widget.onAutoModeChanged!(!_isManualMode);
    }

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isManualMode
              ? '🔧 Mode Manual Diaktifkan'
              : '🤖 Mode Otomatis Diaktifkan',
        ),
        backgroundColor: _isManualMode ? Colors.blue : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    Logger().i("🔄 Mode switched to: ${_isManualMode ? 'MANUAL' : 'AUTO'}");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.indigo[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildModeToggle(),
            // Tampilkan kontrol hanya saat mode manual aktif
            if (_isManualMode) ...[
              const SizedBox(height: 16),
              _buildModeControls(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.engineering, color: Colors.indigo[600], size: 24),
        const SizedBox(width: 12),
        const Text(
          'Kontrol Manual',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isManualMode ? Colors.blue[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isManualMode ? Colors.blue[200]! : Colors.green[200]!,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isManualMode ? Icons.build : Icons.autorenew,
            color: _isManualMode ? Colors.blue[600] : Colors.green[600],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isManualMode ? 'Mode Manual' : 'Mode Otomatis',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isManualMode ? Colors.blue[700] : Colors.green[700],
                  ),
                ),
                Text(
                  _isManualMode
                      ? 'Tap untuk kembali ke Otomatis'
                      : 'Tap untuk aktifkan Manual',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isManualMode ? Colors.blue[600] : Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _isManualMode,
              onChanged: (value) => _toggleMode(),
              activeColor: Colors.blue[600],
              activeTrackColor: Colors.blue[200],
              inactiveThumbColor: Colors.green[600],
              inactiveTrackColor: Colors.green[200],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header untuk kontrol manual
          Row(
            children: [
              Icon(Icons.tune, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Kontrol Aktif',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row untuk 2 tombol mode berdampingan
          Row(
            children: [
              // Mode Pengisian
              Expanded(
                child: _buildModeButton(
                  icon: Icons.input,
                  label: 'Isi',
                  subtitle: 'Pengisian',
                  isActive: _isFillModeActive,
                  color: Colors.lightBlue,
                  onPressed: _toggleFillMode,
                ),
              ),
              const SizedBox(width: 12),

              // Mode Pembuangan
              Expanded(
                child: _buildModeButton(
                  icon: Icons.output,
                  label: 'Buang',
                  subtitle: 'Pembuangan',
                  isActive: _isDrainModeActive,
                  color: Colors.orange,
                  onPressed: _toggleDrainMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isActive,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? color : Colors.grey[600], size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? color : Colors.grey[600],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? color.withOpacity(0.8) : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers - hapus pump dan valve handlers
  Future<void> _toggleFillMode() async {
    final result = _isFillModeActive
        ? await _controlService.deactivateFillMode(widget.poolName)
        : await _controlService.activateFillMode(widget.poolName);

    setState(() {
      _isFillModeActive = result['isFillModeActive']!;
      _isDrainModeActive = result['isDrainModeActive']!;
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFillModeActive
              ? '💧 Mode Pengisian Diaktifkan'
              : '💧 Mode Pengisian Dinonaktifkan',
        ),
        backgroundColor: _isFillModeActive ? Colors.lightBlue : Colors.grey,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _toggleDrainMode() async {
    final result = _isDrainModeActive
        ? await _controlService.deactivateDrainMode(widget.poolName)
        : await _controlService.activateDrainMode(widget.poolName);

    setState(() {
      _isFillModeActive = result['isFillModeActive']!;
      _isDrainModeActive = result['isDrainModeActive']!;
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isDrainModeActive
              ? '🚿 Mode Pembuangan Diaktifkan'
              : '🚿 Mode Pembuangan Dinonaktifkan',
        ),
        backgroundColor: _isDrainModeActive ? Colors.orange : Colors.grey,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
