// lib/providers/app_settings_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsProvider with ChangeNotifier {
  bool _isSafetyTimerEnabled = true; // Defaultnya aktif
  bool _isSchedulerEnabled = false;
  bool _isAutoModeEnabled = false; // Ubah dari var ke bool

  bool get isSafetyTimerEnabled => _isSafetyTimerEnabled;
  bool get isSchedulerEnabled => _isSchedulerEnabled;
  bool get isAutoModeEnabled => _isAutoModeEnabled; // Tambahkan getter

  AppSettingsProvider() {
    _loadSettings();
  }

  // Muat pengaturan dari memori HP
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isSafetyTimerEnabled = prefs.getBool('safetyTimer') ?? true;
    _isSchedulerEnabled = prefs.getBool('scheduler') ?? false;
    _isAutoModeEnabled =
        prefs.getBool('autoMode') ?? false; // Tambahkan loading
    notifyListeners();
  }

  // Simpan pengaturan Timer Pengaman
  Future<void> setSafetyTimerEnabled(bool value) async {
    _isSafetyTimerEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('safetyTimer', value);
    notifyListeners();
  }

  // Simpan pengaturan Jadwal
  Future<void> setSchedulerEnabled(bool value) async {
    _isSchedulerEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('scheduler', value);
    notifyListeners();
  }

  // Tambahkan method ini
  Future<void> setAutoMode(bool value) async {
    _isAutoModeEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoMode', value);
    notifyListeners();
  }
}
