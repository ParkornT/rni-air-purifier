import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _darkMode = true;
  bool get darkMode => _darkMode;

  void toggleTheme() {
    _darkMode = !_darkMode;
    notifyListeners();
  }
}
