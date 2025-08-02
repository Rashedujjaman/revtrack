import 'package:flutter/material.dart';

/// Service class for displaying consistent snackbar messages throughout the app
/// 
/// Features:
/// - Standardized success and error message styling
/// - Floating behavior for better visual integration
/// - Consistent duration and color theming
/// - White text on colored backgrounds for accessibility
/// - Easy integration across all screens and widgets
class SnackbarService {
  /// Displays a success message with green background
  /// 
  /// Parameters:
  /// - [context]: BuildContext for showing the snackbar
  /// - [message]: Success message text to display
  void successMessage(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Displays an error message with red background
  /// 
  /// Parameters:
  /// - [context]: BuildContext for showing the snackbar
  /// - [message]: Error message text to display
  void errorMessage(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
