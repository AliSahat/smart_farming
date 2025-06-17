// lib/widgets/dashboard/header_widget.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../shared/status_indicator.dart';

class HeaderWidget extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onSettingsTap;

  const HeaderWidget({
    super.key,
    required this.isConnected,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isNarrowScreen = constraints.maxWidth < 500;

        return Card(
          elevation: 2.0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[50]!.withOpacity(0.5),
                  Colors.green[50]!.withOpacity(0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: isNarrowScreen
                ? _buildNarrowLayout(context)
                : _buildWideLayout(context),
          ),
        );
      },
    );
  }

  // Layout untuk layar lebar (tablet, desktop)
  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        // Icon dan Title
        Row(
          children: [
            Icon(Icons.agriculture, size: 32, color: Colors.green[600]),
            const SizedBox(width: 12),
            _buildTitle(),
          ],
        ),
        const Spacer(),
        // Status dan Settings
        Row(
          children: [
            StatusIndicator(
              label: isConnected ? 'Terhubung' : 'Terputus',
              color: isConnected ? Colors.green[600]! : Colors.red[600]!,
              icon: Icons.power_settings_new,
            ),
            const SizedBox(width: 16),
            _buildSettingsButton(),
          ],
        ),
      ],
    );
  }

  // Layout untuk layar sempit (HP)
  Widget _buildNarrowLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan icon dan title
        Row(
          children: [
            Icon(Icons.agriculture, size: 28, color: Colors.green[600]),
            const SizedBox(width: 10),
            Expanded(child: _buildTitle()),
          ],
        ),
        const SizedBox(height: 16),
        // Status dan Settings dalam satu baris
        Row(
          children: [
            Expanded(
              child: StatusIndicator(
                label: isConnected ? 'Terhubung' : 'Terputus',
                color: isConnected ? Colors.green[600]! : Colors.red[600]!,
                icon: Icons.power_settings_new,
              ),
            ),
            const SizedBox(width: 12),
            _buildSettingsButton(),
          ],
        ),
      ],
    );
  }

  // Widget untuk Title dan Subtitle
  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Smart Farming Control',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sistem Monitoring Ketinggian Air Otomatis',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  // Widget untuk tombol settings
  Widget _buildSettingsButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: IconButton(
        icon: Icon(Icons.settings, color: Colors.blue[700]),
        onPressed: onSettingsTap,
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }
}
