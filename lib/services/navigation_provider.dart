import 'package:flutter/foundation.dart';

/// Navigation state provider for main app navigation
/// 
/// Manages the current tab index for bottom navigation bar and provides
/// convenient methods for navigating between main app sections.
/// Implements ChangeNotifier for reactive UI updates.
/// 
/// Features:
/// - Current tab index state management
/// - Navigation helper methods for each main section
/// - Efficient change detection to prevent unnecessary rebuilds
class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  /// Gets the current active tab index
  int get currentIndex => _currentIndex;

  /// Sets the current tab index and notifies listeners if changed
  /// 
  /// Parameters:
  /// - [index]: Tab index to navigate to (0-3)
  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// Navigation helper methods for each main section
  void goToDashboard() => setCurrentIndex(0);
  void goToBusiness() => setCurrentIndex(1);
  void goToBankAccounts() => setCurrentIndex(2);
  void goToProfile() => setCurrentIndex(3);
}
