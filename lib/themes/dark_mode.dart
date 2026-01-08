import 'package:flutter/material.dart';

ThemeData darkmode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: const Color.fromRGBO(30, 30, 30, 1),
    primary: const Color.fromRGBO(119, 147, 169, 1),
    secondary: const Color.fromRGBO(83, 102, 118, 1),
    tertiary: const Color.fromRGBO(84, 83, 51, 1),
    onSurface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  ),
  scaffoldBackgroundColor: const Color.fromRGBO(18, 18, 18, 1),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color.fromRGBO(30, 30, 30, 1),
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(color: Colors.white),
    labelLarge: TextStyle(color: Colors.white),
  ),
  iconTheme: const IconThemeData(
    color: Colors.white,
  ),
  listTileTheme: const ListTileThemeData(
    textColor: Colors.white,
    iconColor: Colors.white,
    tileColor: Color.fromRGBO(30, 30, 30, 1),
  ),
  expansionTileTheme: const ExpansionTileThemeData(
    textColor: Colors.white,
    iconColor: Colors.white,
    collapsedTextColor: Colors.white,
    collapsedIconColor: Colors.white,
    backgroundColor: Color.fromRGBO(30, 30, 30, 1),
    collapsedBackgroundColor: Color.fromRGBO(30, 30, 30, 1),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color.fromRGBO(30, 30, 30, 1),
    indicatorColor: const Color.fromARGB(255, 9, 56, 94),
    labelTextStyle: WidgetStateProperty.all(
      const TextStyle(color: Colors.white),
    ),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);