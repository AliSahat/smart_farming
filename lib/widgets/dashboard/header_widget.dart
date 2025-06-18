// lib/widgets/dashboard/header_widget.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget {
  final String userName;
  final bool connectionStatus;

  const HeaderWidget({
    super.key,
    required this.userName,
    required this.connectionStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon dan Title - lebih compact
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.agriculture,
              size: 20,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(width: 12),

          // Title - lebih simple
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Farming',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Monitoring Air Otomatis',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),

          // Status indicator - minimal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: connectionStatus
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: connectionStatus
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  connectionStatus ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: connectionStatus
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Settings button - minimal
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                size: 16,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                _showOptionsMenu(context);
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              icon: Icons.refresh,
              title: 'Refresh Data',
              onTap: () {
                Navigator.pop(context);
                // Implement refresh functionality
              },
            ),
            _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Info Sistem',
              onTap: () {
                Navigator.pop(context);
                _showSystemInfo(context);
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: 'Bantuan',
              onTap: () {
                Navigator.pop(context);
                // Implement help functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.grey.shade600),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showSystemInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue, size: 20),
            SizedBox(width: 8),
            Text('Info Sistem', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem('Versi Aplikasi:', '1.0.0'),
            _buildInfoItem(
              'Status Koneksi:',
              connectionStatus ? 'Terhubung' : 'Terputus',
            ),
            _buildInfoItem('Pengguna:', userName),
            _buildInfoItem(
              'Waktu Aktif:',
              '${DateTime.now().hour}:${DateTime.now().minute}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
