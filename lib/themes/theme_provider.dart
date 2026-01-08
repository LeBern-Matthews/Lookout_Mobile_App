import 'package:flutter/material.dart';
import 'light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightmode; 

  ThemeData get themeData => _themeData;

  void setTheme(ThemeData theme) {
    _themeData = theme;
    notifyListeners();
  }
}