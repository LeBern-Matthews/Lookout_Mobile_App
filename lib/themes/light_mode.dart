import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: const Color.fromRGBO(244, 240, 220, 20), // the background colour
    primary: const Color.fromRGBO(187, 222, 251, 1),
    secondary: const Color.fromARGB(255, 132, 192, 240),
    tertiary: const Color.fromRGBO(109, 106, 66, 10),
  ).copyWith(
    brightness: Brightness.light,
    primary: const Color.fromRGBO(187, 222, 251, 1),
    surface: const Color.fromRGBO(244, 240, 220, 20),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);