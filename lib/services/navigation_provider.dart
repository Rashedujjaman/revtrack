import 'package:flutter/foundation.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void goToDashboard() => setCurrentIndex(0);
  void goToBusiness() => setCurrentIndex(1);
  void goToProfile() => setCurrentIndex(2);
}
