import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyNotifications = 'notifications_enabled';
  static const _keySensitivity = 'sensitivity_level';
  static const _keyDarkMode = 'dark_mode';

  final SupabaseClient? _client;

  bool _notificationsEnabled = true;
  // 0=Düşük, 1=Orta, 2=Yüksek
  int _sensitivityLevel = 1;
  bool _darkMode = false;

  SettingsProvider({SupabaseClient? client}) : _client = client {
    // Oturum değiştiğinde Supabase'deki ayarları yeniden yükle
    _client?.auth.onAuthStateChange.listen((_) {
      loadFromRemote();
    });
  }

  bool get notificationsEnabled => _notificationsEnabled;
  int get sensitivityLevel => _sensitivityLevel;
  bool get darkMode => _darkMode;
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_keyNotifications) ?? true;
    _sensitivityLevel = prefs.getInt(_keySensitivity) ?? 1;
    _darkMode = prefs.getBool(_keyDarkMode) ?? false;
    notifyListeners();
    // Oturum varsa uzak ayarları yükle
    await loadFromRemote();
  }

  /// Supabase user metadata'sından ayarları yükle (varsa).
  Future<void> loadFromRemote() async {
    final user = _client?.auth.currentUser;
    if (user == null) return;
    try {
      final meta = user.userMetadata;
      if (meta == null) return;
      final n = meta['notifications_enabled'];
      final s = meta['sensitivity_level'];
      final d = meta['dark_mode'];
      if (n is bool) _notificationsEnabled = n;
      if (s is int) _sensitivityLevel = s;
      if (d is bool) _darkMode = d;
      notifyListeners();
    } catch (e) {
      debugPrint('SettingsProvider.loadFromRemote hata: $e');
    }
  }

  /// Mevcut değerleri Supabase user metadata'sına yaz.
  Future<void> _syncToRemote() async {
    final client = _client;
    if (client == null || client.auth.currentUser == null) return;
    try {
      await client.auth.updateUser(UserAttributes(data: {
        'notifications_enabled': _notificationsEnabled,
        'sensitivity_level': _sensitivityLevel,
        'dark_mode': _darkMode,
      }));
    } catch (e) {
      debugPrint('SettingsProvider._syncToRemote hata: $e');
    }
  }

  Future<void> setNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
    await _syncToRemote();
  }

  Future<void> setSensitivity(int value) async {
    _sensitivityLevel = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySensitivity, value);
    await _syncToRemote();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
    await _syncToRemote();
  }
}
