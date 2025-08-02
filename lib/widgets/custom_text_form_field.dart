import 'package:flutter/material.dart';

/// Custom text form field widget with consistent theming and validation
/// 
/// Features:
/// - Consistent Material Design 3 theming
/// - Built-in validation support
/// - Obscure text option for passwords
/// - Floating label behavior control
/// - Custom fill colors and keyboard types
/// - Theme-aware styling with primary colors
class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final bool filled;
  final Color? fillColor;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  /// Creates a custom text form field with theming and validation
  /// 
  /// Parameters:
  /// - [controller]: Text editing controller for field state
  /// - [label]: Required label text for the field
  /// - [hintText]: Optional placeholder text
  /// - [obscureText]: Whether to hide text (for passwords)
  /// - [filled]: Whether field should have background fill
  /// - [fillColor]: Custom fill color (defaults to theme colors)
  /// - [floatingLabelBehavior]: How label floats (auto, always, never)
  /// - [keyboardType]: Input type for soft keyboard
  /// - [validator]: Validation function returning error message
  const CustomTextFormField({
    Key? key,
    this.controller,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.filled = true,
    this.fillColor,
    this.floatingLabelBehavior = FloatingLabelBehavior.auto,
    this.keyboardType,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      obscuringCharacter: '*',
      keyboardType: keyboardType,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: filled,
        fillColor: Theme.of(context).colorScheme.brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.secondary.withAlpha(200),
        iconColor: Theme.of(context).colorScheme.primary,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: floatingLabelBehavior,
        floatingLabelAlignment: FloatingLabelAlignment.start,
      ),
      validator: validator,
    );
  }
}
