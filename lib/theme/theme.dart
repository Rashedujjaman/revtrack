import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      background: Color(0xFF64E6F0),
      inversePrimary: Colors.white,
      primary: Colors.black,
      secondary: Colors.grey,
      tertiary: Colors.amber,
    ));

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      background: Colors.black,
      inversePrimary: Color(0xFF64E6F0),
      primary: Colors.white,
      secondary: Colors.grey,
      tertiary: Colors.amber,
    ));
