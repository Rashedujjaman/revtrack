import 'package:flutter/material.dart';

/// User state provider for managing current user ID across the app
/// 
/// Provides centralized user ID state management with automatic
/// UI updates through ChangeNotifier. Used throughout the app
/// to access current user context for Firebase operations.
/// 
/// Features:
/// - Current user ID state management
/// - Automatic UI updates when user state changes
/// - Clear user state on logout
/// - Simple getter/setter pattern for user ID
class UserProvider with ChangeNotifier {
  String _userId = '';

  /// Gets the current user ID
  String get userId => _userId;

  /// Sets the current user ID and notifies listeners
  /// 
  /// Parameters:
  /// - [id]: Firebase user UID to set as current user
  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }

  /// Clears the current user ID (used on logout)
  void clearUserId() {
    _userId = '';
    notifyListeners();
  }
}
