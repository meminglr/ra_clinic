import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  FlexScheme _selectedScheme = FlexScheme.shadGreen;
  final Box _box = Hive.box('settingsBox');

  ThemeProvider() {
    _isDark = _box.get('isDark', defaultValue: false);
    final int? savedSchemeIndex = _box.get('selectedScheme');
    if (savedSchemeIndex != null &&
        savedSchemeIndex >= 0 &&
        savedSchemeIndex < FlexScheme.values.length) {
      _selectedScheme = FlexScheme.values[savedSchemeIndex];
    }
  }

  bool get isDark => _isDark;
  FlexScheme get scheme => _selectedScheme;

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

  void setScheme(FlexScheme scheme) {
    _selectedScheme = scheme;
    _box.put('selectedScheme', scheme.index);
    notifyListeners();
  }
}
