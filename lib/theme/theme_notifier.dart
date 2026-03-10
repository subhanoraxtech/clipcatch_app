import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.get(_prefsKey);
    _themeMode = switch (raw) {
      // Preferred storage (string)
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,

      // Back-compat: some builds may have stored an int index.
      // 1=light, 2=dark (common convention).
      1 => ThemeMode.light,
      2 => ThemeMode.dark,

      // Back-compat: tolerate bool values.
      true => ThemeMode.dark,
      false => ThemeMode.light,

      _ => ThemeMode.dark,
    };

    // Normalize stored value to string for future reads.
    await prefs.setString(_prefsKey, switch (_themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'dark',
    });
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;

    // Update UI instantly
    notifyListeners();

    // Save to preferences in background (don't await)
    _saveThemeAsync(mode);
  }

  Future<void> _saveThemeAsync(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'dark',
    });
  }
}

final themeNotifier = ThemeNotifier();
