import 'package:flutter/material.dart';

BoxDecoration gradientBackground(BuildContext context) {
  bool isLightMode = Theme.of(context).brightness == Brightness.light;
  return BoxDecoration(
    gradient: LinearGradient(
      colors: isLightMode
          ? [
              const Color(0xFF64E6F0),
              Colors.white,
              const Color(0xFF64E6F0),
            ]
          : [
              Colors.transparent,
              Colors.grey[800]!,
              Colors.transparent,
            ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );
}
