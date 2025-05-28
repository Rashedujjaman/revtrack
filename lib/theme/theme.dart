import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      // surface: const Color(0xFF64E6F0),
      surface: Colors.white,
      // surfaceDim: const Color.fromARGB(255, 168, 249, 255),
      surfaceDim: Colors.grey[200]!,
      inversePrimary: Colors.grey[100]!,
      primary: Colors.black,
      secondary: Colors.grey.shade300,
      tertiary: Colors.amber,
      surfaceContainerHighest: Colors.grey[300]!,
    ));

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.black,
      surfaceDim: Colors.grey[800]!,
      // inversePrimary: const Color(0xFF64E6F0),
      inversePrimary: Colors.grey[900]!,
      primary: Colors.white,
      secondary: Colors.grey.shade700,
      tertiary: Colors.amber,
      surfaceContainerHighest: Colors.grey[700]!,
    ));
