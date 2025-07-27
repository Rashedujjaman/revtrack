import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:revtrack/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  // Default to system theme
  ThemeData _themeData = lightMode;
  bool _isDarkMode = false;
  bool _isInitialized = false;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Load theme from SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey);

      if (isDark != null) {
        _isDarkMode = isDark;
        _themeData = _isDarkMode ? darkMode : lightMode;
      } else {
        // First time, use system brightness
        final brightness = PlatformDispatcher.instance.platformBrightness;
        _isDarkMode = brightness == Brightness.dark;
        _themeData = _isDarkMode ? darkMode : lightMode;
        await _saveThemeToPrefs(); // Save the system preference
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Fallback to system brightness if SharedPreferences fails
      final brightness = PlatformDispatcher.instance.platformBrightness;
      _isDarkMode = brightness == Brightness.dark;
      _themeData = _isDarkMode ? darkMode : lightMode;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Save theme to SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      // Handle error silently
      debugPrint('Failed to save theme preference: $e');
    }
  }

  // Toggle theme method
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? darkMode : lightMode;

    // Save to preferences
    await _saveThemeToPrefs();

    // Notify listeners
    notifyListeners();
  }

  // Set specific theme
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _themeData = _isDarkMode ? darkMode : lightMode;

      // Save to preferences
      await _saveThemeToPrefs();

      // Notify listeners
      notifyListeners();
    }
  }
}
