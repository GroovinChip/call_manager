import 'package:flutter/material.dart';

extension MediaQueryX on MediaQueryData {
  bool get keyboardOpen => this.viewInsets.bottom != 0;
}

extension ThemeModeExtensions on ThemeMode {
  String format() {
    String themeModeDisplay;
    switch (this) {
      case ThemeMode.system:
        themeModeDisplay = 'System default';
        break;
      case ThemeMode.light:
        themeModeDisplay = 'Light theme';
        break;
      case ThemeMode.dark:
        themeModeDisplay = 'Dark theme';
        break;
    }

    return themeModeDisplay;
  }
}

extension BuildContextX on BuildContext {
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}
