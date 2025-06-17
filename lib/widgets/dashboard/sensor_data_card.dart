// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../models/pool_model.dart';
import '../shared/custom_card.dart';

class SensorDataCard extends StatelessWidget {
  final double waterLevel;
  final bool isConnected;
  final String poolName;

  const SensorDataCard({
    Key? key,
    required this.waterLevel,
    required this.isConnected,
    required this.poolName,
  }) : super(key: key);

  Color _getWaterLevelColor() {
    if (waterLevel < 30) return Colors.orange;
    if (waterLevel > 80) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.regular),
          _buildDataList(),
          const SizedBox(height: AppSpacing.regular),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Sensor Data', style: AppTextStyles.heading),
        _buildConnectionStatus(),
      ],
    );
  }

  Widget _buildConnectionStatus() {
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
        const SizedBox(width: AppSpacing.tiny),
        Text(
          isConnected ? 'Online' : 'Offline',
          style: TextStyle(
            fontSize: 10,
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
        const SizedBox(height: AppSpacing.medium),
        _buildDataItem(
          icon: Icons.water_drop,
          label: 'Level Air',
          value: '${waterLevel.toStringAsFixed(1)}%',
          color: _getWaterLevelColor(),
        ),
        const SizedBox(height: AppSpacing.medium),
        _buildDataItem(
          icon: Icons.thermostat,
          label: 'Suhu Air',
          value: '26.5°C',
          color: Colors.orange,
        ),
        const SizedBox(height: AppSpacing.medium),
        _buildDataItem(
          icon: Icons.schedule,
          label: 'Update Terakhir',
          value: DateTime.now().toString().substring(11, 19),
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickStat('Hari Ini', '45', 'Pembacaan'),
          Container(height: 30, width: 1, color: Colors.grey[300]),
          _buildQuickStat('Minggu Ini', '312', 'Pembacaan'),
        ],
      ),
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
        Icon(icon, color: color, size: 24),
        const SizedBox(width: AppSpacing.medium),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStat(String title, String value, String unit) {
    return Column(
      children: [
        Text(title, style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.tiny),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(unit, style: AppTextStyles.caption),
      ],
    );
  }
}
