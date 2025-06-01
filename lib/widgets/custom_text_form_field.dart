import 'package:flutter/material.dart';

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
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: filled,
        fillColor: Theme.of(context).colorScheme.brightness == Brightness.light
            ? Colors.white
            : Theme.of(context).colorScheme.secondary.withValues(
                  alpha: 200,
                ),
        iconColor: Theme.of(context).colorScheme.primary,
        border: const OutlineInputBorder(),
        floatingLabelBehavior: floatingLabelBehavior,
        floatingLabelAlignment: FloatingLabelAlignment.start,
      ),
      validator: validator,
    );
  }
}
