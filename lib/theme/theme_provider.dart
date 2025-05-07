import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:revtrack/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  //Check device brightness and set theme accordingly
  ThemeData _themeData =
      PlatformDispatcher.instance.platformBrightness == Brightness.dark
          ? darkMode
          : lightMode;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
