import 'package:flutter/material.dart';
import 'package:soul_talk/themes/dark_theme.dart';
import 'package:soul_talk/themes/light_theme.dart';

// This helps us to switch between themes like dark mode and light mode

class ThemeProvider with ChangeNotifier {
  //initially ,set it as light mode
  ThemeData _themeData = lightMode;

  //get the current theme
  ThemeData get themeData => _themeData;

  //is it dark mode currently-?
  bool get isDarkMode => _themeData == darkMode;

  //set the theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;

    //update UI
    notifyListeners();
  }

  //toggle method
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
