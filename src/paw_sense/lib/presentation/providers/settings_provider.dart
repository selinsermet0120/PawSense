import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyNotifications = 'notifications_enabled';
  static const _keySensitivity = 'sensitivity_level';
  static const _keyDarkMode = 'dark_mode';

  bool _notificationsEnabled = true;
  // 0=Düşük, 1=Orta, 2=Yüksek
  int _sensitivityLevel = 1;
  bool _darkMode = false;

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
  }

  Future<void> setNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, value);
  }

  Future<void> setSensitivity(int value) async {
    _sensitivityLevel = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySensitivity, value);
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }
}
