import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:revtrack/theme/theme.dart';

/// Theme provider for managing app-wide theme state
/// 
/// Features:
/// - Dark/light theme switching with persistence
/// - System theme detection on first launch
/// - SharedPreferences integration for theme persistence
/// - Initialization state tracking for splash screens
/// - ChangeNotifier integration for reactive UI updates
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  // Theme state variables
  ThemeData _themeData = lightMode;
  bool _isDarkMode = false;
  bool _isInitialized = false;

  // Getters for theme state
  ThemeData get themeData => _themeData;
  bool get isDarkMode => _isDarkMode;
  bool get isInitialized => _isInitialized;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  /// Loads saved theme preference from SharedPreferences
  /// Falls back to system brightness on first launch or error
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

  /// Saves current theme preference to SharedPreferences
  Future<void> _saveThemeToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }

  /// Toggles between dark and light theme
  /// Saves preference and notifies listeners
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    _themeData = _isDarkMode ? darkMode : lightMode;

    await _saveThemeToPrefs();
    notifyListeners();
  }

  /// Sets specific theme mode
  /// 
  /// Parameters:
  /// - [isDark]: true for dark theme, false for light theme
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
