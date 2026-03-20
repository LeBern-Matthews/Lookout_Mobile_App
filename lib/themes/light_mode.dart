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
  ),
  
  
  listTileTheme: ListTileThemeData(
    
    tileColor:  Colors.white,
    selectedTileColor:  Color.fromARGB(255,245, 244, 242),
    selectedColor: Color.fromARGB(254, 147, 146, 144)
    //iconColor: Colors.orange,
    //selectedTileColor: Color.fromARGB(255,210,207,202,)
  ),
  
  cardTheme: CardThemeData(
    color:const Color.fromARGB(255,210,207,202,),
  ),


  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);