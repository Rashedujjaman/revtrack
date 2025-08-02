import 'package:flutter/material.dart';

/// Provides theme-aware gradient background decoration
/// 
/// Features:
/// - Automatic light/dark mode detection
/// - Cyan-to-white gradient for light mode with visual depth
/// - Transparent-to-grey gradient for dark mode with subtle contrast
/// - Vertical gradient alignment from top to bottom
/// - Seamless integration with Material Design 3 color schemes
/// 
/// Returns: BoxDecoration with linear gradient based on current theme
BoxDecoration gradientBackground(BuildContext context) {
  bool isLightMode = Theme.of(context).brightness == Brightness.light;
  
  return BoxDecoration(
    gradient: LinearGradient(
      colors: isLightMode
          ? [
              const Color(0xFF64E6F0), // Cyan top
              Colors.white,             // White middle
              const Color(0xFF64E6F0), // Cyan bottom
            ]
          : [
              Colors.transparent,       // Transparent top
              Colors.grey[800]!,        // Dark grey middle
              Colors.transparent,       // Transparent bottom
            ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );
}
