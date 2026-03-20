import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: const Color.fromARGB(100,241, 244, 248), // the background colour
    primary: const Color.fromRGBO(187, 222, 251, 1),
    secondary: const Color.fromARGB(255, 209, 228, 255),
    tertiary: const Color.fromARGB(255, 209, 228, 255),
    
  ).copyWith(
    brightness: Brightness.light,
    primary: const Color.fromRGBO(31, 116, 223, 1),
    surface: const Color.fromRGBO(238,237,233, 1),
   secondary: const Color.fromARGB(255, 209, 228, 255),
  ),listTileTheme: ListTileThemeData(
    //tileColor: const Color.fromARGB(255, 255, 236, 209),
    selectedTileColor: const Color.fromARGB(255, 255, 236, 209),
    iconColor: Colors.orange,
  ),
 // cardColor:  Colors.red,
  
  cardTheme: CardThemeData(
    color:const Color.fromARGB(255, 255, 255, 255),
  ),


  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);