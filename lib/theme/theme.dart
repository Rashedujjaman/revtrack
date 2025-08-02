import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      surface: Colors.white,
      onSurface: Colors.black,
      surfaceDim: Colors.grey[200]!,
      surfaceContainer: Colors.grey[100]!,
      inversePrimary: Colors.grey[100]!,
      primary: Colors.black,
      secondary: Colors.grey.shade300,
      tertiary: Colors.amber,
      surfaceContainerHighest: Colors.grey[300]!,
      // Set status bar and navigation bar colors and icon brightness based on theme mode
    ));

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.black,
      onSurface: Colors.white,
      surfaceDim: Colors.grey[800]!,
      surfaceContainer: Colors.grey[900]!,
      inversePrimary: Colors.grey[900]!,
      primary: Colors.white,
      secondary: Colors.grey.shade700,
      tertiary: const Color.fromARGB(255, 212, 162, 13),
      surfaceContainerHighest: Colors.grey[700]!,
    ));
