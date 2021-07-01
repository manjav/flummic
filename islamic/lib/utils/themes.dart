import 'package:flutter/material.dart';

class Themes {
  static Map<int, Color> get primaries => <int, Color>{
        0: Color(0xFF50E0E0),
        50: Color(0xFFF0F9FF),
        100: Color(0xFFD2E6F0),
        150: Color(0xFF445555),
        200: Color(0xFF90C0CB),
        300: Color(0xFF4DAFB6),
        400: Color(0xFF269DA6),
        500: Color(0xFF008C96),
        600: Color(0xFF005560),
        700: Color(0xFF003540),
        750: Color(0xFF00203A),
        800: Color(0xFF051A2A),
        900: Color(0xFF051222),
        910: Color(0xFF5A5A4A),
        920: Color(0xFF3A3A2A),
      };

  static ThemeData get data {
    var hl = TextStyle(color: primaries[920], fontWeight: FontWeight.bold);
    var textTheme = TextTheme(
        bodyText1: TextStyle(color: primaries[920]),
        bodyText2: TextStyle(color: primaries[920]),
        subtitle1: TextStyle(
            color: primaries[920], fontSize: 15, fontWeight: FontWeight.bold),
        subtitle2: TextStyle(color: primaries[910], fontSize: 12),
        headline1: hl,
        headline2: hl,
        headline3: hl,
        headline4: hl,
        headline5: TextStyle(
            color: hl.color, fontWeight: FontWeight.bold, fontSize: 21),
        headline6: TextStyle(color: hl.color, fontSize: 17),
        caption: TextStyle(
            color: primaries[910], fontSize: 15, fontWeight: FontWeight.w100),
        button: TextStyle(color: primaries[50], fontWeight: FontWeight.normal));

    Color getTextButtonColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) return primaries[300]!;
      return primaries[states.contains(MaterialState.disabled) ? 600 : 400]!;
    }

    var iconTheme = IconThemeData(color: primaries[50]);
    return ThemeData(
        primarySwatch: material,
        iconTheme: iconTheme,
        appBarTheme: AppBarTheme(
            backgroundColor: primaries[500],
            textTheme: textTheme,
            iconTheme: iconTheme),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: primaries[500], foregroundColor: primaries[100]),
        sliderTheme: SliderThemeData(
            thumbColor: primaries[700],
            activeTrackColor: primaries[300],
            inactiveTrackColor: primaries[300],
            overlayColor: primaries[200]),
        textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
                foregroundColor:
                    MaterialStateProperty.resolveWith(getTextButtonColor),
                textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                    fontFamily: "CubicSans",
                    fontSize: 18,
                    fontWeight: FontWeight.bold)))),
        textSelectionTheme: TextSelectionThemeData(
            cursorColor: primaries[600],
            selectionHandleColor: primaries[600],
            selectionColor: primaries[300]),
        snackBarTheme: SnackBarThemeData(
            contentTextStyle: TextStyle(fontFamily: "CubicSans", fontSize: 16),
            backgroundColor: primaries[500],
            actionTextColor: primaries[50]),
        inputDecorationTheme:
            InputDecorationTheme(hintStyle: TextStyle(color: primaries[150])),
        fontFamily: "CubicSans",
        accentColor: primaries[600],
        buttonColor: primaries[400],
        scaffoldBackgroundColor: primaries[50],
        backgroundColor: primaries[50],
        cardColor: primaries[100],
        primaryColor: primaries[500],
        focusColor: primaries[300],
        textTheme: textTheme,
        dialogBackgroundColor: primaries[100],
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
            ));
  }

  static ThemeData get darkData {
    var hl = TextStyle(color: primaries[100], fontWeight: FontWeight.bold);
    var textTheme = TextTheme(
        bodyText1: TextStyle(color: primaries[100]),
        bodyText2: TextStyle(color: primaries[200]),
        subtitle1: TextStyle(
            color: primaries[100], fontSize: 15, fontWeight: FontWeight.bold),
        subtitle2: TextStyle(color: primaries[200], fontSize: 12),
        headline1: hl,
        headline2: hl,
        headline3: hl,
        headline4: hl,
        headline5: TextStyle(
            color: hl.color, fontWeight: FontWeight.bold, fontSize: 21),
        headline6: TextStyle(color: hl.color, fontSize: 17),
        caption: TextStyle(
            color: primaries[200], fontSize: 15, fontWeight: FontWeight.w100),
        button:
            TextStyle(color: primaries[100], fontWeight: FontWeight.normal));

    Color getTextButtonColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) return primaries[300]!;
      return primaries[states.contains(MaterialState.disabled) ? 600 : 400]!;
    }

    var iconTheme = IconThemeData(color: primaries[50]);

    return ThemeData(
      primarySwatch: darkMaterial,
      iconTheme: iconTheme,
      appBarTheme: AppBarTheme(
          backgroundColor: primaries[700],
          textTheme: textTheme,
          iconTheme: iconTheme),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaries[500], foregroundColor: primaries[100]),
      sliderTheme: SliderThemeData(
          thumbColor: primaries[300],
          activeTrackColor: primaries[700],
          inactiveTrackColor: primaries[700],
          overlayColor: primaries[700]),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              foregroundColor:
                  MaterialStateProperty.resolveWith(getTextButtonColor),
              textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                  fontFamily: "CubicSans",
                  fontSize: 18,
                  fontWeight: FontWeight.bold)))),
      textSelectionTheme: TextSelectionThemeData(
          cursorColor: primaries[500],
          selectionHandleColor: primaries[300],
          selectionColor: primaries[600]),
      snackBarTheme: SnackBarThemeData(
          contentTextStyle: TextStyle(fontFamily: "CubicSans", fontSize: 16),
          backgroundColor: primaries[700],
          actionTextColor: primaries[500]),
      inputDecorationTheme:
          InputDecorationTheme(hintStyle: TextStyle(color: primaries[150])),
      fontFamily: "CubicSans",
      accentColor: primaries[0],
      buttonColor: primaries[600],
      scaffoldBackgroundColor: primaries[900],
      backgroundColor: primaries[900],
      cardColor: primaries[800],
      primaryColor: primaries[700],
      focusColor: primaries[750],
      textTheme: textTheme,
      dialogBackgroundColor: primaries[800],
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
      MaterialColor(primaries[500]!.value, primaries);
  static MaterialColor get darkMaterial =>
      MaterialColor(primaries[900]!.value, primaries);
}
