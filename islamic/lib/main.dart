import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islamic/models.dart';
import 'package:islamic/utils.dart';
import 'package:islamic/waiting.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  static int t;
  @override
  AppState createState() => AppState();
  static AppState of(BuildContext context) =>
      context.findAncestorStateOfType<AppState>();
}

class AppState extends State<MyApp> {
  Locale locale;
  bool configured = false;
  WaitingPage waitingPage;
  var supportedLocales = [
    const Locale("en", ""),
    const Locale("fa", ""),
  ];

  @override
  void initState() {
    MyApp.t = DateTime.now().millisecondsSinceEpoch;
    super.initState();
    waitingPage = WaitingPage();
    Prefs.init(() {
      Utils.getLocale();
      Configs.create(() {
        if (waitingPage.onLoop)
          waitingPage.finish(() {
            setState(() => configured = true);
          });
        else
          setState(() => configured = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Title Example',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      locale: locale,
      // debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: "CubicSans"),
      home: configured ? HomePage() : waitingPage,
    );
  }

  void setLocale(String lang) {
    var _loc = supportedLocales.firstWhere((l) => l.languageCode == lang);
    if (_loc == null) return;
    setState(() {
      locale = _loc;
    });
  }
}
