import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/controllers/theme_controller.dart';

void main() {
  group('ThemeController', () {
    test('defaults to dark mode', () {
      final controller = ThemeController();
      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);
    });

    test('toggleTheme updates state', () {
      final controller = ThemeController();
      controller.toggleTheme(false);
      expect(controller.themeMode, ThemeMode.light);
      expect(controller.isDarkMode, isFalse);

      controller.toggleTheme(true);
      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.isDarkMode, isTrue);
    });
  });
}

