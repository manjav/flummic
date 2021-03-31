import 'package:flutter/material.dart';

class Themes {
  static Map<int, Color> get primaries => <int, Color>{
        50: Color(0xFFF0F9FF),
        100: Color(0xFFD2E6F0),
        200: Color(0xFF90C6CB),
        300: Color(0xFF4DAFB6),
        400: Color(0xFF269DA6),
        500: Color(0xFF008C96),
        600: Color(0xFF005560),
        700: Color(0xFF003540),
        800: Color(0xFF001A2A),
        900: Color(0xFF001525),
        910: Color(0xFF5A5A4A),
        920: Color(0xFF3A3A2A),
      };

  static ThemeData get data {
    var textTheme = TextTheme(
        bodyText1: TextStyle(color: primaries[920]),
        bodyText2: TextStyle(color: primaries[920]),
        subtitle1: TextStyle(color: primaries[920]),
        caption: TextStyle(color: primaries[910]),
        button: TextStyle(color: primaries[50]),
        headline6: TextStyle(
            color: primaries[100],
            fontFamily: "CubicSans",
            fontSize: 21,
            fontWeight: FontWeight.bold));
    return ThemeData(
        primarySwatch: material,
        appBarTheme: AppBarTheme(
            backgroundColor: primaries[500],
            textTheme: textTheme,
            iconTheme: IconThemeData(color: Colors.white)),
        scaffoldBackgroundColor: primaries[50],
        backgroundColor: primaries[50],
        cardColor: primaries[100],
        primaryColor: primaries[500],
        focusColor: primaries[50],
        textTheme: textTheme,
        colorScheme: ColorScheme.light(
            // primary: primaries[500],
            // onPrimary: Colors.white,
            // primaryVariant: Colors.teal[50],
            // background: primaries[50],
            // onBackground: primaries[100],
            // surface: Colors.red,
            // secondary: Colors.teal[50],
            // onSecondary: Colors.red,
            // secondaryVariant: Colors.red,
            ),
        fontFamily: "CubicSans");
  }

  static ThemeData get darkData {
    var textTheme = TextTheme(
        bodyText1: TextStyle(color: primaries[100]),
        bodyText2: TextStyle(color: primaries[100]),
        subtitle1: TextStyle(color: primaries[100]),
        subtitle2: TextStyle(color: primaries[100]),
        caption: TextStyle(color: primaries[200]),
        button: TextStyle(color: primaries[900]),
        headline6: TextStyle(
            color: primaries[100],
            fontFamily: "CubicSans",
            fontSize: 21,
            fontWeight: FontWeight.bold));
    return ThemeData(
      primarySwatch: darkMaterial,
      appBarTheme: AppBarTheme(
          backgroundColor: primaries[700],
          textTheme: textTheme,
          iconTheme: IconThemeData(color: primaries[100])),
      fontFamily: "CubicSans",
      scaffoldBackgroundColor: primaries[900],
      backgroundColor: primaries[900],
      cardColor: primaries[800],
      primaryColor: primaries[700],
      focusColor: primaries[100],
      textTheme: textTheme,
      colorScheme: ColorScheme.dark(
          // primary: primaries[700],
          // onPrimary: Colors.white,
          // primaryVariant: Colors.teal[50],
          // background: primaries[900],
          // onBackground: primaries[800],
          // surface: Colors.red,
          // secondary: Colors.teal[50],
          // onSecondary: Colors.red,
          // secondaryVariant: Colors.red,
          ),
    );
  }

  static MaterialColor get material =>
      MaterialColor(primaries[500].value, primaries);
  static MaterialColor get darkMaterial =>
      MaterialColor(primaries[900].value, primaries);
}
