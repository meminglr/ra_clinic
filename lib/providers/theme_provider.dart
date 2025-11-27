import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  final Box _box = Hive.box('settings');

  ThemeProvider() {
    _isDark = _box.get('isDark', defaultValue: false);
  }

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark = !_isDark;
    _box.put('isDark', _isDark); // Hive’a kaydet
    notifyListeners();
  }

  void setDark(bool value) {
    _isDark = value;
    _box.put('isDark', _isDark); // Hive’a kaydet
    notifyListeners();
  }
}