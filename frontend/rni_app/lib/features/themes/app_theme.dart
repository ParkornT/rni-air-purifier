import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  colorScheme: const ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.orange,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromARGB(255, 10, 0, 40),
    //foregroundColor: Colors.white,
  ),
  navigationRailTheme: const NavigationRailThemeData(
    backgroundColor: Color.fromARGB(255, 0, 0, 40),
    indicatorColor: Colors.orange,
  ),
  colorScheme: const ColorScheme.dark(
    primary: Colors.blue,
    secondary: Colors.orange,
  ),
  dividerTheme: const DividerThemeData(
    color: Colors.blueGrey,
    thickness: 1,
    space: 1,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  ),
);
