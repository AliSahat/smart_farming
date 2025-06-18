// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../models/esp_water_data.dart';

class SensorDataCard extends StatelessWidget {
  final ESPWaterData? latestWaterData;
  final VoidCallback onToggleSettings;
  final bool showSettings;
  final double waterLevelPercent; // Tambah parameter ini
  final String poolName; // Tambah parameter ini

  const SensorDataCard({
    super.key,
    required this.latestWaterData,
    required this.onToggleSettings,
    required this.showSettings,
    required this.waterLevelPercent,
    required this.poolName,
  });

  Color _getWaterLevelColor() {
    if (waterLevelPercent < 30) return Colors.orange;
    if (waterLevelPercent > 80) return Colors.red;
    return Colors.blue;
  }

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
            _buildHeader(),
            const SizedBox(height: 16),
            _buildDataList(),
            const SizedBox(height: 16),
            _buildQuickStats(),
            const SizedBox(height: 16),
            _buildToggleButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Data Sensor',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        _buildConnectionStatus(),
      ],
    );
  }

  Widget _buildConnectionStatus() {
    final isConnected = latestWaterData?.isSuccess ?? false;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isConnected ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isConnected ? Colors.green[700] : Colors.red[700],
          ),
        ),
      ],
    );
  }

  Widget _buildDataList() {
    return Column(
      children: [
        _buildDataItem(
          icon: Icons.pool,
          label: 'Kolam/Wadah',
          value: poolName,
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildDataItem(
          icon: Icons.water_drop,
          label: 'Level Air',
          value: '${waterLevelPercent.toStringAsFixed(1)}%',
          color: _getWaterLevelColor(),
        ),
        const SizedBox(height: 12),
        _buildDataItem(
          icon: Icons.height,
          label: 'Jarak Sensor',
          value: latestWaterData != null
              ? '${latestWaterData!.distanceToWater.toStringAsFixed(1)} cm'
              : 'N/A',
          color: Colors.teal,
        ),
        const SizedBox(height: 12),
        _buildDataItem(
          icon: Icons.schedule,
          label: 'Update Terakhir',
          value: latestWaterData != null
              ? '${latestWaterData!.timestamp.hour.toString().padLeft(2, '0')}:${latestWaterData!.timestamp.minute.toString().padLeft(2, '0')}:${latestWaterData!.timestamp.second.toString().padLeft(2, '0')}'
              : 'N/A',
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildDataItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Status',
            latestWaterData?.isSuccess == true ? 'Normal' : 'Error',
            latestWaterData?.isSuccess == true ? Colors.green : Colors.red,
          ),
          _buildStatItem('Mode', 'Otomatis', Colors.blue),
          _buildStatItem('Refresh', '10s', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildToggleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onToggleSettings,
        icon: Icon(
          showSettings ? Icons.visibility_off : Icons.settings,
          size: 18,
        ),
        label: Text(
          showSettings ? 'Sembunyikan Pengaturan' : 'Tampilkan Pengaturan',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
