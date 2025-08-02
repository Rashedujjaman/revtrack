import 'package:flutter/material.dart';

/// Light theme configuration for the application
/// 
/// Features:
/// - Material Design 3 color scheme compliance
/// - High contrast with black primary on white surface
/// - Grey-based secondary colors for subtle UI elements
/// - Amber tertiary color for accent highlights
/// - Optimized for daylight viewing and accessibility
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
  ),
);

/// Dark theme configuration for the application
/// 
/// Features:
/// - Material Design 3 dark mode compliance
/// - True black surface with white primary text
/// - Dark grey variations for depth and hierarchy
/// - Golden amber tertiary for warm accent highlights
/// - Optimized for low-light viewing and reduced eye strain
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
  ),
);
