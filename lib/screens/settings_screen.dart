// ignore_for_file: deprecated_member_use, unnecessary_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _autoMode = true;
  bool _notifications = true;
  bool _soundAlerts = false;
  bool _darkMode = false;
  double _updateInterval = 5.0; // seconds
  String _language = 'id';

  // Advanced features
  bool _isSafetyTimerEnabled = false;
  bool _isSchedulerEnabled = false;

  final TextEditingController _serverUrlController = TextEditingController(
    text: 'http://192.168.1.100:8080',
  );
  final TextEditingController _deviceIdController = TextEditingController(
    text: 'SF001',
  );

  @override
  void dispose() {
    _serverUrlController.dispose();
    _deviceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Advanced Features & Time Settings
            _buildSettingsSection(
              title: 'Fitur Lanjutan & Waktu',
              icon: Icons.timer_outlined,
              children: [
                _buildSwitchTile(
                  title: 'Timer Pengaman',
                  subtitle:
                      'Hentikan aksi jika kran/pompa terlalu lama menyala',
                  value: _isSafetyTimerEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isSafetyTimerEnabled = value;
                    });
                  },
                  icon: Icons.security_rounded,
                ),
                const Divider(height: 24),
                _buildSwitchTile(
                  title: 'Jadwal Ganti Air',
                  subtitle:
                      'Aktifkan penggantian air terjadwal (Contoh: Minggu, 07:00)',
                  value: _isSchedulerEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isSchedulerEnabled = value;
                    });
                  },
                  icon: Icons.event_note_rounded,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // System Settings
            _buildSettingsSection(
              title: 'Pengaturan Sistem',
              icon: Icons.settings,
              children: [
                _buildSwitchTile(
                  title: 'Mode Otomatis',
                  subtitle: 'Kontrol otomatis berdasarkan sensor',
                  value: _autoMode,
                  onChanged: (value) {
                    setState(() {
                      _autoMode = value;
                    });
                  },
                  icon: Icons.auto_mode,
                ),
                _buildSliderTile(
                  title: 'Interval Update',
                  subtitle: '${_updateInterval.toInt()} detik',
                  value: _updateInterval,
                  min: 1.0,
                  max: 60.0,
                  divisions: 59,
                  onChanged: (value) {
                    setState(() {
                      _updateInterval = value;
                    });
                  },
                  icon: Icons.timer,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notification Settings
            _buildSettingsSection(
              title: 'Notifikasi',
              icon: Icons.notifications,
              children: [
                _buildSwitchTile(
                  title: 'Aktifkan Notifikasi',
                  subtitle: 'Terima notifikasi sistem',
                  value: _notifications,
                  onChanged: (value) {
                    setState(() {
                      _notifications = value;
                    });
                  },
                  icon: Icons.notifications_active,
                ),
                _buildSwitchTile(
                  title: 'Suara Peringatan',
                  subtitle: 'Bunyi saat ada peringatan',
                  value: _soundAlerts,
                  onChanged: (value) {
                    setState(() {
                      _soundAlerts = value;
                    });
                  },
                  icon: Icons.volume_up,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Connection Settings
            _buildSettingsSection(
              title: 'Koneksi',
              icon: Icons.wifi,
              children: [
                _buildTextFieldTile(
                  title: 'URL Server',
                  controller: _serverUrlController,
                  icon: Icons.link,
                  hint: 'http://192.168.1.100:8080',
                ),
                const SizedBox(height: 12),
                _buildTextFieldTile(
                  title: 'ID Perangkat',
                  controller: _deviceIdController,
                  icon: Icons.device_hub,
                  hint: 'SF001',
                ),
                const SizedBox(height: 12),
                _buildActionTile(
                  title: 'Test Koneksi',
                  subtitle: 'Coba hubungkan ke server',
                  icon: Icons.network_check,
                  onTap: _testConnection,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // App Settings
            _buildSettingsSection(
              title: 'Aplikasi',
              icon: Icons.phone_android,
              children: [
                _buildDropdownTile(
                  title: 'Bahasa',
                  value: _language,
                  items: const [
                    DropdownMenuItem(
                      value: 'id',
                      child: Text('Bahasa Indonesia'),
                    ),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _language = value!;
                    });
                  },
                  icon: Icons.language,
                ),
                _buildSwitchTile(
                  title: 'Mode Gelap',
                  subtitle: 'Tema gelap untuk aplikasi',
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                  icon: Icons.dark_mode,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // About & Actions
            _buildSettingsSection(
              title: 'Tentang',
              icon: Icons.info,
              children: [
                _buildActionTile(
                  title: 'Versi Aplikasi',
                  subtitle: 'v1.0.0 (Build 1)',
                  icon: Icons.app_settings_alt,
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
                _buildActionTile(
                  title: 'Reset Pengaturan',
                  subtitle: 'Kembalikan ke pengaturan default',
                  icon: Icons.restore,
                  onTap: _resetSettings,
                  textColor: Colors.orange,
                ),
                _buildActionTile(
                  title: 'Hapus Data',
                  subtitle: 'Hapus semua data aplikasi',
                  icon: Icons.delete_forever,
                  onTap: _clearAllData,
                  textColor: Colors.red,
                ),
                _buildActionTile(
                  title: 'Reset Panduan',
                  subtitle: 'Tampilkan panduan awal lagi',
                  icon: Icons.help_outline,
                  onTap: _resetOnBoarding,
                  textColor: Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue[600], size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue[600], size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue[600],
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[600], size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(subtitle),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: Colors.blue[600],
        ),
      ],
    );
  }

  Widget _buildTextFieldTile({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[600], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue[400]!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue[600], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: value,
                items: items,
                onChanged: onChanged,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.blue[400]!),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (textColor ?? Colors.blue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: textColor ?? Colors.blue[600], size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: textColor),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _saveSettings() {
    // Implement save logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pengaturan disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _testConnection() {
    // Implement connection test
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Menguji koneksi...'),
          ],
        ),
      ),
    );

    // Simulate network test
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Koneksi berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Smart Farming Control',
      applicationVersion: 'v1.0.0',
      applicationIcon: const Icon(
        Icons.agriculture,
        size: 48,
        color: Colors.green,
      ),
      children: [
        const Text(
          'Aplikasi kontrol sistem smart farming untuk monitoring dan kontrol otomatis kolam/wadah air.',
        ),
      ],
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Pengaturan'),
        content: const Text(
          'Yakin ingin mengembalikan semua pengaturan ke default?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _autoMode = true;
                _notifications = true;
                _soundAlerts = false;
                _darkMode = false;
                _updateInterval = 5.0;
                _language = 'id';
                _isSafetyTimerEnabled = false;
                _isSchedulerEnabled = false;
                _serverUrlController.text = 'http://192.168.1.100:8080';
                _deviceIdController.text = 'SF001';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan direset ke default'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data'),
        content: const Text(
          'PERINGATAN: Ini akan menghapus semua data aplikasi termasuk histori dan pengaturan. Tindakan ini tidak bisa dibatalkan!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur hapus data akan segera tersedia'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetOnBoarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Panduan akan ditampilkan saat aplikasi dimulai ulang'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
