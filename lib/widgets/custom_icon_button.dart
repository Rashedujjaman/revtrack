import 'package:flutter/material.dart';

/// Custom icon button widget with enhanced styling and theming
/// 
/// Features:
/// - Customizable button size and border radius
/// - Theme-aware background and border colors
/// - Configurable elevation and padding
/// - Material Design 3 compliance
/// - Consistent styling across the app
/// - Null safety for optional press handling
class CustomIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double borderWidth;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final double? iconSize;
  final double size;

  /// Creates a custom icon button with advanced styling options
  /// 
  /// Parameters:
  /// - [onPressed]: Callback function when button is tapped
  /// - [icon]: Required icon to display in the button
  /// - [backgroundColor]: Custom background color (defaults to scaffold background)
  /// - [borderColor]: Custom border color (defaults to secondary theme color)
  /// - [borderRadius]: Corner radius for rounded appearance (default: 8.0)
  /// - [borderWidth]: Width of the border line (default: 1.0)
  /// - [elevation]: Material elevation shadow (default: 0.0)
  /// - [padding]: Internal padding for the button (default: EdgeInsets.zero)
  /// - [iconSize]: Size of the icon (defaults to theme icon size)
  /// - [size]: Overall button size as square dimensions (default: 40)
  const CustomIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 8.0,
    this.borderWidth = 1.0,
    this.elevation = 0.0,
    this.padding = EdgeInsets.zero,
    this.iconSize,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            width: borderWidth,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        padding: padding,
        elevation: elevation,
        minimumSize: Size.square(size),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
