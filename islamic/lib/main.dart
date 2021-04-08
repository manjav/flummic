import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islamic/pages/Index.dart';
import 'package:islamic/widgets/player.dart';

import 'models.dart';
import 'pages/waiting.dart';
import 'utils/themes.dart';

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
  Player player;
  ThemeMode themeMode;
  int loadingState = 0;
  WaitingPage waitingPage;
  var supportedLocales = [
    const Locale("ar", ""),
    const Locale("en", ""),
    const Locale("es", ""),
    const Locale("fa", ""),
    const Locale("fr", ""),
    const Locale("id", ""),
    const Locale("ru", ""),
    const Locale("tr", ""),
    const Locale("ur", "")
  ];

  @override
  void initState() {
    MyApp.t = DateTime.now().millisecondsSinceEpoch;
    super.initState();
    waitingPage = WaitingPage();
    Prefs.init(() {
      setState(() => loadingState = 1);
      setTheme(ThemeMode.values[Prefs.instance.getInt("themeMode")]);
      Configs.create(() {
        if (waitingPage.page.state > 1)
          waitingPage.page.end(() {
            setState(() => loadingState = 2);
          });
        else
          setState(() => loadingState = 2);
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
      theme: Themes.data,
      darkTheme: Themes.darkData,
      themeMode: themeMode,
      home: preparedPage(),
    );
  }

  Widget preparedPage() {
    switch (loadingState) {
      case 1:
        return waitingPage;
      case 2:
        return IndexPage();
      default:
        return Container(color: Colors.red);
    }
  }

  void setTheme(ThemeMode mode) {
    if (themeMode == mode) return;
    themeMode = mode;
    Prefs.instance.setInt("themeMode", mode.index);
    setState(() {});
  }

  void setLocale(String lang) {
    var _loc = supportedLocales.firstWhere((l) => l.languageCode == lang);
    if (_loc == null) return;
    setState(() {
      locale = _loc;
      Prefs.instance.setString("locale", lang);
    });
  }
}
