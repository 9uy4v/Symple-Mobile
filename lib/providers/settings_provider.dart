import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:symple_mobile/main.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;

  SettingsProvider() {
    SharedPreferences.getInstance().then(
      (value) {
        _prefs = value;
        _getTheme();
      },
    );
  }

  void _getTheme() {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final isLight =
        _prefs.getBool('isLightMode') ?? brightness == Brightness.light;

    isLight ? themeMode.add(ThemeMode.light) : themeMode.add(ThemeMode.dark);
    notifyListeners();
  }

  void switchTheme() {
    // TO DO : in settings show 3 options- dark,light and system default. in case of system default delete prefrence.
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;

    bool currentState =
        _prefs.getBool('isLightMode') ?? brightness == Brightness.light;

    _prefs.setBool('isLightMode', !currentState);

    _getTheme();
  }
}
