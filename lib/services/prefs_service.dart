import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  PrefsService._();

  static Future<PrefsService> init() async {
    final bloc = PrefsService._();
    await bloc._init();

    return bloc;
  }

  Future<void> _init() async {
    preferences = await SharedPreferences.getInstance();
    readThemeModePref();
  }

  SharedPreferences preferences;
  final themeModeSubject = BehaviorSubject<ThemeMode>();
  ThemeMode get currentThemeMode => themeModeSubject.value;

  Future<void> setThemeModePref(ThemeMode themeMode) async {
    await preferences.setString('themeModePref', '${themeMode.toString()}');
    themeModeSubject.add(themeMode);
  }

  void readThemeModePref() {
    String tm = preferences.get('themeModePref') ?? 'ThemeMode.system';
    ThemeMode themeMode =
        ThemeMode.values.firstWhere((element) => element.toString() == tm);
    themeModeSubject.add(themeMode);
  }

  void close() {
    themeModeSubject.close();
  }
}
