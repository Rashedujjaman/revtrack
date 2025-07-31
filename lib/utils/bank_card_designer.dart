import 'package:flutter/material.dart';
import 'dart:math' as math;

class BankCardDesigner {
  static const Map<String, List<Color>> _bankColorSchemes = {
    // Popular Bangladeshi Banks
    'dbbl': [Color(0xFF1E3A8A), Color(0xFF60A5FA), Color(0xFF1D4ED8)],
    'ibbl': [Color(0xFF059669), Color(0xFF34D399), Color(0xFF10B981)],
    'brac': [Color(0xFFDC2626), Color(0xFFF87171), Color(0xFFEF4444)],
    'standard': [Color(0xFF7C3AED), Color(0xFFA78BFA), Color(0xFF8B5CF6)],
    'city': [Color(0xFFEA580C), Color(0xFFFB923C), Color(0xFFF97316)],
    'bank asia': [Color(0xFF0891B2), Color(0xFF67E8F9), Color(0xFF06B6D4)],
    'southeast': [Color(0xFFDB2777), Color(0xFFF472B6), Color(0xFFEC4899)],
    'prime': [Color(0xFF16A34A), Color(0xFF4ADE80), Color(0xFF22C55E)],
    'pubali': [Color(0xFF7C2D12), Color(0xFFFB7185), Color(0xFFDC2626)],
    'ebl': [Color.fromARGB(255, 233, 218, 8), Color.fromARGB(200, 179, 167, 7), Color.fromARGB(255, 209, 223, 23)],
    'mercantile': [Color(0xFF6366F1), Color(0xFF818CF8), Color(0xFF6366F1)],
    'ab': [Color.fromARGB(255, 233, 212, 203), Color.fromARGB(255, 206, 9, 9), Color.fromARGB(255, 255, 255, 255)],
    'nrbc': [Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFF7C3AED)],
    'ucb': [Color.fromARGB(255, 230, 226, 226), Color.fromARGB(255, 255, 30, 0), Color.fromARGB(255, 54, 30, 30)],

    
    // International Banks
    'hsbc': [Color(0xFFDC2626), Color(0xFFEF4444), Color(0xFFF87171)],
    'citibank': [Color(0xFF1E40AF), Color(0xFF3B82F6), Color(0xFF60A5FA)],
    'standard chartered': [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
    
    // Default colors for unknown banks
    'default': [Color(0xFF6B7280), Color(0xFF9CA3AF), Color(0xFFD1D5DB)],
  };

  static const Map<String, int> _bankPatterns = {
    'dutch-bangla': 0,
    'ibbl': 1,
    'brac': 2,
    'standard': 3,
    'city': 4,
    'bank asia': 5,
    'southeast': 6,
    'prime': 7,
    'eastern': 8,
    'mercantile': 9,
    'ab': 10,
    'nrbc': 11,
    'ucb': 12,
    'hsbc': 13,
    'citibank': 14,
    'standard chartered': 15,
    'default': 13,


  };

  static List<Color> getBankColors(String bankName) {
    final normalizedName = bankName.toLowerCase().trim();
    
    // Try exact match first
    if (_bankColorSchemes.containsKey(normalizedName)) {
      return _bankColorSchemes[normalizedName]!;
    }
    
    // Try partial matches
    for (final key in _bankColorSchemes.keys) {
      if (normalizedName.contains(key) || key.contains(normalizedName)) {
        return _bankColorSchemes[key]!;
      }
    }
    
    // Generate deterministic colors based on bank name hash
    final hash = bankName.hashCode;
    final hue = (hash % 360).toDouble();
    final baseColor = HSVColor.fromAHSV(1.0, hue, 0.7, 0.8).toColor();
    final lightColor = HSVColor.fromAHSV(1.0, hue, 0.4, 0.9).toColor();
    final darkColor = HSVColor.fromAHSV(1.0, hue, 0.8, 0.6).toColor();
    
    return [baseColor, lightColor, darkColor];
  }

  static int getBankPattern(String bankName) {
    final normalizedName = bankName.toLowerCase().trim();
    
    if (_bankPatterns.containsKey(normalizedName)) {
      return _bankPatterns[normalizedName]!;
    }
    
    // Generate pattern based on bank name hash
    return bankName.hashCode % 8;
  }

  static Widget createGeometricPattern(List<Color> colors, int patternType, Size size) {
    return CustomPaint(
      size: size,
      painter: GeometricPatternPainter(colors, patternType),
    );
  }
}

class GeometricPatternPainter extends CustomPainter {
  final List<Color> colors;
  final int patternType;

  GeometricPatternPainter(this.colors, this.patternType);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    switch (patternType % 8) {
      case 0:
        _drawDiagonalStripes(canvas, size, paint);
        break;
      case 1:
        _drawCircularPattern(canvas, size, paint);
        break;
      case 2:
        _drawTrianglePattern(canvas, size, paint);
        break;
      case 3:
        _drawWavePattern(canvas, size, paint);
        break;
      case 4:
        _drawHexagonPattern(canvas, size, paint);
        break;
      case 5:
        _drawDiamondPattern(canvas, size, paint);
        break;
      case 6:
        _drawSpiraPattern(canvas, size, paint);
        break;
      case 7:
        _drawPolygonPattern(canvas, size, paint);
        break;
    }
  }

  void _drawDiagonalStripes(Canvas canvas, Size size, Paint paint) {
    final stripeWidth = size.width / 8;
    for (int i = 0; i < 16; i++) {
      paint.color = colors[i % colors.length].withValues(alpha: 0.3);
      final path = Path();
      path.moveTo(i * stripeWidth - size.height, 0);
      path.lineTo(i * stripeWidth, 0);
      path.lineTo(i * stripeWidth - size.height, size.height);
      path.lineTo(i * stripeWidth - size.height - stripeWidth, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawCircularPattern(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width * 0.8;
    final centerY = size.height * 0.3;
    for (int i = 0; i < 5; i++) {
      paint.color = colors[i % colors.length].withValues(alpha: 0.2 + i * 0.1);
      canvas.drawCircle(
        Offset(centerX, centerY),
        (i + 1) * 20,
        paint,
      );
    }
  }

  void _drawTrianglePattern(Canvas canvas, Size size, Paint paint) {
    final triangleSize = size.width / 6;
    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 4; y++) {
        paint.color = colors[(x + y) % colors.length].withValues(alpha: 0.25);
        final path = Path();
        final centerX = x * triangleSize - triangleSize;
        final centerY = y * triangleSize - triangleSize;
        path.moveTo(centerX, centerY);
        path.lineTo(centerX + triangleSize, centerY);
        path.lineTo(centerX + triangleSize / 2, centerY + triangleSize);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawWavePattern(Canvas canvas, Size size, Paint paint) {
    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i].withValues(alpha: 0.3);
      final path = Path();
      path.moveTo(0, size.height * 0.5 + i * 15);
      
      for (double x = 0; x <= size.width; x += 10) {
        final y = size.height * 0.5 + 
                  math.sin((x + i * 50) * math.pi / 180) * 30 + 
                  i * 15;
        path.lineTo(x, y);
      }
      
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawHexagonPattern(Canvas canvas, Size size, Paint paint) {
    final hexSize = 30.0;
    for (int x = 0; x < (size.width / hexSize).ceil() + 2; x++) {
      for (int y = 0; y < (size.height / hexSize).ceil() + 2; y++) {
        paint.color = colors[(x + y) % colors.length].withValues(alpha: 0.2);
        final centerX = x * hexSize * 0.75 - hexSize;
        final centerY = y * hexSize + (x % 2) * hexSize * 0.5 - hexSize;
        
        _drawHexagon(canvas, Offset(centerX, centerY), hexSize / 2, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawDiamondPattern(Canvas canvas, Size size, Paint paint) {
    final diamondSize = 40.0;
    for (int x = 0; x < (size.width / diamondSize).ceil() + 2; x++) {
      for (int y = 0; y < (size.height / diamondSize).ceil() + 2; y++) {
        paint.color = colors[(x + y) % colors.length].withValues(alpha: 0.25);
        final centerX = x * diamondSize - diamondSize;
        final centerY = y * diamondSize - diamondSize;
        
        final path = Path();
        path.moveTo(centerX, centerY - diamondSize / 2);
        path.lineTo(centerX + diamondSize / 2, centerY);
        path.lineTo(centerX, centerY + diamondSize / 2);
        path.lineTo(centerX - diamondSize / 2, centerY);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  void _drawSpiraPattern(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width * 0.7, size.height * 0.4);
    final maxRadius = math.min(size.width, size.height) * 0.6;
    
    for (int i = 0; i < colors.length; i++) {
      paint.color = colors[i].withValues(alpha: 0.3);
      final path = Path();
      
      for (double angle = 0; angle < math.pi * 6; angle += 0.1) {
        final radius = (angle / (math.pi * 6)) * maxRadius + i * 10;
        final x = center.dx + radius * math.cos(angle + i);
        final y = center.dy + radius * math.sin(angle + i);
        
        if (angle == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawPath(path, paint);
      paint.style = PaintingStyle.fill;
    }
  }

  void _drawPolygonPattern(Canvas canvas, Size size, Paint paint) {
    final polygonSize = 35.0;
    for (int x = 0; x < (size.width / polygonSize).ceil() + 2; x++) {
      for (int y = 0; y < (size.height / polygonSize).ceil() + 2; y++) {
        paint.color = colors[(x + y) % colors.length].withValues(alpha: 0.3);
        final centerX = x * polygonSize - polygonSize;
        final centerY = y * polygonSize - polygonSize;
        
        _drawPolygon(canvas, Offset(centerX, centerY), polygonSize / 2, 5 + (x + y) % 3, paint);
      }
    }
  }

  void _drawPolygon(Canvas canvas, Offset center, double radius, int sides, Paint paint) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi) / sides;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
