import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: const Color(0xFF64E6F0),
      inversePrimary: Colors.white,
      primary: Colors.black,
      secondary: Colors.grey.shade500,
      tertiary: Colors.amber,
      surfaceContainerHighest: Colors.grey[300]!,
    ));

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.black,
      inversePrimary: const Color(0xFF64E6F0),
      primary: Colors.white,
      secondary: Colors.grey.shade800,
      tertiary: Colors.amber,
      surfaceContainerHighest: Colors.grey[700]!,
    ));
