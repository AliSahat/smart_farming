// ignore_for_file: unused_element, unused_import

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:smart_farming/helper/notification_service.dart';
import 'package:smart_farming/screens/service_layer/manual_control_service.dart';

class ManualControlCard extends StatefulWidget {
  final bool isAutoModeEnabled;
  final String? poolName;
  final NotificationService notificationService;

  const ManualControlCard({
    super.key,
    required this.isAutoModeEnabled,
    required this.poolName,
    required this.notificationService,
  });

  @override
  State<ManualControlCard> createState() => _ManualControlCardState();
}

class _ManualControlCardState extends State<ManualControlCard> {
  late final ManualControlService _controlService;

  // Manual control states
  bool _isPumpRunning = false;
  bool _isValveOpen = false;
  bool _isFillModeActive = false;
  bool _isDrainModeActive = false;

  @override
  void initState() {
    super.initState();
    _controlService = ManualControlService(widget.notificationService);
    Logger().i("🏁 Manual controls initialized for pool: ${widget.poolName}");
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
            const SizedBox(height: 8),
            _buildModeWarning(),
            const SizedBox(height: 16),
            _buildManualControls(),
            const SizedBox(height: 12),
            _buildModeControls(),
            const SizedBox(height: 16),
            _buildEmergencyStop(),
            const SizedBox(height: 8),
            _buildTestButton(),
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

  Widget _buildModeWarning() {
    if (widget.isAutoModeEnabled) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.amber[600], size: 16),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Mode otomatis aktif. Kontrol manual mungkin tidak tersedia.',
                style: TextStyle(fontSize: 12, color: Colors.amber),
              ),
            ),
          ],
        ),
      );
    } else {
      return const Text(
        'Mode manual aktif - Kontrol penuh tersedia',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }
  }

  Widget _buildManualControls() {
    return Row(
      children: [
        Expanded(
          child: _buildControlButton(
            icon: Icons.water_drop,
            label: 'Pompa',
            subtitle: _isPumpRunning ? 'Menyala' : 'Mati',
            isActive: _isPumpRunning,
            isEnabled: !widget.isAutoModeEnabled,
            color: Colors.blue,
            onPressed: !widget.isAutoModeEnabled ? _togglePump : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildControlButton(
            icon: Icons.water,
            label: 'Keran',
            subtitle: _isValveOpen ? 'Terbuka' : 'Tertutup',
            isActive: _isValveOpen,
            isEnabled: !widget.isAutoModeEnabled,
            color: Colors.green,
            onPressed: !widget.isAutoModeEnabled ? _toggleValve : null,
          ),
        ),
      ],
    );
  }

  Widget _buildModeControls() {
    return Row(
      children: [
        Expanded(
          child: _buildModeButton(
            icon: Icons.input,
            label: 'Mode Isi',
            isActive: _isFillModeActive,
            isEnabled: !widget.isAutoModeEnabled,
            color: Colors.blue,
            onPressed: !widget.isAutoModeEnabled ? _toggleFillMode : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildModeButton(
            icon: Icons.output,
            label: 'Mode Buang',
            isActive: _isDrainModeActive,
            isEnabled: !widget.isAutoModeEnabled,
            color: Colors.orange,
            onPressed: !widget.isAutoModeEnabled ? _toggleDrainMode : null,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyStop() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _emergencyStop,
        icon: const Icon(Icons.stop, size: 20),
        label: const Text(
          'STOP DARURAT',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _testValveNotifications,
        icon: const Icon(Icons.notifications_active, size: 20),
        label: const Text('Test Notifikasi Valve'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[100],
          foregroundColor: Colors.purple[700],
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isActive,
    required bool isEnabled,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isEnabled
              ? (isActive ? color.withOpacity(0.1) : Colors.grey[50])
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? (isActive ? color : Colors.grey[300]!)
                : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? (isActive ? color : Colors.grey[600])
                  : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isEnabled ? Colors.black87 : Colors.grey[500],
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isEnabled ? Colors.grey[600] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isEnabled,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isEnabled
              ? (isActive ? color.withOpacity(0.1) : Colors.grey[50])
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? (isActive ? color : Colors.grey[300]!)
                : Colors.grey[300]!,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? (isActive ? color : Colors.grey[600])
                  : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isEnabled ? Colors.black87 : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  Future<void> _togglePump() async {
    Logger().d("👆 Pump button pressed, current state: $_isPumpRunning");
    final newState = await _controlService.togglePump(
      _isPumpRunning,
      widget.poolName,
    );
    setState(() {
      _isPumpRunning = newState;
      Logger().d("🔄 Pump state updated to: $newState");
    });
  }

  Future<void> _toggleValve() async {
    Logger().d("👆 Valve button pressed, current state: $_isValveOpen");
    final newState = await _controlService.toggleValve(
      _isValveOpen,
      widget.poolName,
    );
    setState(() {
      _isValveOpen = newState;
      Logger().d("🔄 Valve state updated to: $newState");
    });
  }

  Future<void> _toggleFillMode() async {
    final result = _isFillModeActive
        ? await _controlService.deactivateFillMode(widget.poolName)
        : await _controlService.activateFillMode(widget.poolName);

    setState(() {
      _isPumpRunning = result['isPumpRunning']!;
      _isValveOpen = result['isValveOpen']!;
      _isFillModeActive = result['isFillModeActive']!;
      _isDrainModeActive = result['isDrainModeActive']!;
    });
  }

  Future<void> _toggleDrainMode() async {
    final result = _isDrainModeActive
        ? await _controlService.deactivateDrainMode(widget.poolName)
        : await _controlService.activateDrainMode(widget.poolName);

    setState(() {
      _isPumpRunning = result['isPumpRunning']!;
      _isValveOpen = result['isValveOpen']!;
      _isFillModeActive = result['isFillModeActive']!;
      _isDrainModeActive = result['isDrainModeActive']!;
    });
  }

  Future<void> _emergencyStop() async {
    final result = await _controlService.emergencyStop(widget.poolName);

    setState(() {
      _isPumpRunning = result['isPumpRunning']!;
      _isValveOpen = result['isValveOpen']!;
      _isFillModeActive = result['isFillModeActive']!;
      _isDrainModeActive = result['isDrainModeActive']!;
    });
  }

  void _testValveNotifications() {
    Logger().i("🧪 Starting valve notification tests for: ${widget.poolName}");
    widget.notificationService.sendTestValveNotifications(
      poolName: widget.poolName,
    );
  }
}
