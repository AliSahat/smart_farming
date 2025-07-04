// ignore_for_file: deprecated_member_use, unnecessary_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../providers/pool_provider.dart';
import '../providers/app_settings_provider.dart';
import '../models/pool_model.dart';

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

  // Pool editing controllers
  final TextEditingController _poolNameController = TextEditingController();
  final TextEditingController _poolDepthController = TextEditingController();
  final TextEditingController _poolNormalLevelController = TextEditingController();
  final TextEditingController _poolMaxLevelController = TextEditingController();
  final TextEditingController _poolMinLevelController = TextEditingController();

  String? _selectedPoolKey;
  final _poolFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentPoolData();
    });
  }

  void _loadSettings() {
    Logger().i("🔧 Loading settings screen");
    // Load from providers if available
    final appSettings = Provider.of<AppSettingsProvider>(context, listen: false);
    setState(() {
      _autoMode = appSettings.isAutoModeEnabled ?? true;
      _isSafetyTimerEnabled = appSettings.isSafetyTimerEnabled ?? false;
    });
  }

  void _loadCurrentPoolData() {
    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    if (poolProvider.currentPool != null && poolProvider.selectedPoolKey.isNotEmpty) {
      final currentPool = poolProvider.currentPool!;
      setState(() {
        _selectedPoolKey = poolProvider.selectedPoolKey;
        _poolNameController.text = currentPool.name;
        _poolDepthController.text = currentPool.depth.toStringAsFixed(0);
        _poolNormalLevelController.text = currentPool.normalLevel.toStringAsFixed(0);
        _poolMaxLevelController.text = currentPool.maxLevel.toStringAsFixed(0);
        _poolMinLevelController.text = currentPool.minLevel.toStringAsFixed(0);
      });
      Logger().i("📊 Loaded current pool data: ${currentPool.name}");
    }
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _deviceIdController.dispose();
    _poolNameController.dispose();
    _poolDepthController.dispose();
    _poolNormalLevelController.dispose();
    _poolMaxLevelController.dispose();
    _poolMinLevelController.dispose();
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
            // Pool Settings Section
            _buildPoolSettingsSection(),
            const SizedBox(height: 16),

            // Advanced Features & Time Settings
            _buildSettingsSection(
              title: 'Fitur Lanjutan & Waktu',
              icon: Icons.timer_outlined,
              children: [
                _buildSwitchTile(
                  title: 'Timer Pengaman',
                  subtitle: 'Hentikan aksi jika kran/pompa terlalu lama menyala',
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
                  subtitle: 'Aktifkan penggantian air terjadwal (Contoh: Minggu, 07:00)',
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

  // NEW: Pool Settings Section
  Widget _buildPoolSettingsSection() {
    return Consumer<PoolProvider>(
      builder: (context, poolProvider, child) {
        return _buildSettingsSection(
          title: 'Pengaturan Kolam/Wadah',
          icon: Icons.pool,
          children: [
            // Pool selector dropdown
            if (poolProvider.pools.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _selectedPoolKey,
                decoration: InputDecoration(
                  labelText: 'Pilih Kolam untuk Diedit',
                  prefixIcon: Icon(Icons.pool, color: Colors.blue[600]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: poolProvider.pools.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value.name),
                  );
                }).toList(),
                onChanged: (String? newKey) {
                  if (newKey != null) {
                    _loadPoolDataForEditing(newKey, poolProvider.pools[newKey]!);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],

            // Pool editing form
            if (_selectedPoolKey != null) ...[
              Form(
                key: _poolFormKey,
                child: Column(
                  children: [
                    _buildPoolTextField(
                      controller: _poolNameController,
                      label: 'Nama Kolam/Wadah',
                      icon: Icons.label,
                    ),
                    const SizedBox(height: 12),
                    _buildPoolTextField(
                      controller: _poolDepthController,
                      label: 'Kedalaman Total (cm)',
                      icon: Icons.straighten,
                      isNumeric: true,
                    ),
                    const SizedBox(height: 12),
                    _buildPoolTextField(
                      controller: _poolMinLevelController,
                      label: 'Level Minimum (cm)',
                      icon: Icons.trending_down,
                      isNumeric: true,
                    ),
                    const SizedBox(height: 12),
                    _buildPoolTextField(
                      controller: _poolMaxLevelController,
                      label: 'Level Maksimum (cm)',
                      icon: Icons.trending_up,
                      isNumeric: true,
                    ),
                    const SizedBox(height: 12),
                    _buildPoolTextField(
                      controller: _poolNormalLevelController,
                      label: 'Target Level Normal (cm)',
                      icon: Icons.track_changes,
                      isNumeric: true,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 32),
                    const SizedBox(height: 8),
                    Text(
                      poolProvider.pools.isEmpty
                          ? 'Belum ada kolam yang tersedia.\nTambah kolam dari Dashboard terlebih dahulu.'
                          : 'Pilih kolam dari dropdown di atas untuk mengedit pengaturan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPoolTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumeric = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : null,
      validator: isNumeric
          ? (value) {
              if (value?.isEmpty ?? true) return 'Tidak boleh kosong';
              final num = double.tryParse(value!);
              if (num == null || num <= 0) return 'Harus angka positif';
              return null;
            }
          : (value) {
              if (value?.isEmpty ?? true) return 'Tidak boleh kosong';
              return null;
            },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
        ),
      ),
    );
  }

  void _loadPoolDataForEditing(String poolKey, Pool pool) {
    setState(() {
      _selectedPoolKey = poolKey;
      _poolNameController.text = pool.name;
      _poolDepthController.text = pool.depth.toStringAsFixed(0);
      _poolNormalLevelController.text = pool.normalLevel.toStringAsFixed(0);
      _poolMaxLevelController.text = pool.maxLevel.toStringAsFixed(0);
      _poolMinLevelController.text = pool.minLevel.toStringAsFixed(0);
    });
    Logger().i("📝 Loaded pool data for editing: ${pool.name}");
  }

  // Enhanced save settings method
  void _saveSettings() async {
    Logger().i("💾 Starting to save all settings");
    
    try {
      // Save app settings
      final appSettings = Provider.of<AppSettingsProvider>(context, listen: false);
      await appSettings.setAutoMode(_autoMode);
      await appSettings.setSafetyTimerEnabled(_isSafetyTimerEnabled);
      Logger().i("✅ App settings saved");

      // Save pool settings if pool is selected and form is valid
      if (_selectedPoolKey != null && _poolFormKey.currentState!.validate()) {
        await _savePoolSettings();
      }

      // Save other preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', _notifications);
      await prefs.setBool('sound_alerts_enabled', _soundAlerts);
      await prefs.setBool('dark_mode_enabled', _darkMode);
      await prefs.setDouble('update_interval', _updateInterval);
      await prefs.setString('app_language', _language);
      await prefs.setString('server_url', _serverUrlController.text);
      await prefs.setString('device_id', _deviceIdController.text);
      Logger().i("✅ Preferences saved");

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Expanded(child: Text('Semua pengaturan berhasil disimpan')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      Logger().i("🎉 All settings saved successfully");
    } catch (e) {
      Logger().e("❌ Error saving settings", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error menyimpan pengaturan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePoolSettings() async {
    if (_selectedPoolKey == null) return;

    final poolProvider = Provider.of<PoolProvider>(context, listen: false);
    final currentPool = poolProvider.pools[_selectedPoolKey!];
    if (currentPool == null) return;

    try {
      final newPool = Pool(
        name: _poolNameController.text.trim(),
        depth: double.parse(_poolDepthController.text),
        normalLevel: double.parse(_poolNormalLevelController.text),
        maxLevel: double.parse(_poolMaxLevelController.text),
        minLevel: double.parse(_poolMinLevelController.text),
        currentDepth: currentPool.currentDepth, // Keep current water level
      );

      final success = await poolProvider.updatePool(_selectedPoolKey!, newPool);
      
      if (success) {
        Logger().i("✅ Pool settings updated: ${newPool.name}");
      } else {
        Logger().w("⚠️ Pool update returned false");
      }
    } catch (e) {
      Logger().e("❌ Error updating pool settings", error: e);
      rethrow;
    }
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

  void _testConnection() {
    Logger().i("🔍 Testing connection to server");
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
      Logger().i("✅ Connection test completed");
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
    Logger().i("🔄 Resetting all settings to default");
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
              Logger().i("✅ Settings reset to default");
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
    Logger().w("⚠️ Clear all data requested");
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
              Logger().i("ℹ️ Clear data feature not yet implemented");
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
    Logger().i("🔄 Resetting onboarding status");
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
