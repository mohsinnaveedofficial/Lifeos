import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  ThemeController({ThemeMode initialMode = ThemeMode.dark})
      : _themeMode = initialMode.obs;

  static const String themeKey = 'theme_mode';

  final Rx<ThemeMode> _themeMode;

  ThemeMode get themeMode => _themeMode.value;

  bool get isDarkMode => _themeMode.value == ThemeMode.dark;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(themeKey) ?? 'dark';
      _themeMode.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      _themeMode.value = ThemeMode.dark;
    }
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = mode == ThemeMode.dark ? 'dark' : 'light';
      await prefs.setString(themeKey, themeString);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode.value = mode;
    _saveTheme(mode);
  }

  void toggleTheme(bool isDark) {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _themeMode.value = newMode;
    _saveTheme(newMode);
  }
}

