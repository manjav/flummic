import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islamic/pages/Index.dart';
import 'package:smartlook/smartlook.dart';
import 'package:wakelock/wakelock.dart';

import 'models.dart';
import 'pages/waiting.dart';
import 'utils/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static int? t;

  @override
  AppState createState() => AppState();
  static AppState? of(BuildContext context) =>
      context.findAncestorStateOfType<AppState>();
}

class AppState extends State<MyApp> {
  Locale? locale;
  ThemeMode? themeMode;
  int loadingState = 0;
  WaitingPage? waitingPage;
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

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    Map appsFlyerOptions = {
      "afDevKey": "YBThmUqaiHZYpiSwZ3GQz4",
      "afAppId": "com.gerantech.muslim.holy.quran",
      "isDebug": false
    };

    AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    appsflyerSdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true);

    MyApp.t = DateTime.now().millisecondsSinceEpoch;
    waitingPage = WaitingPage();
    Prefs.init(() {
      setState(() => loadingState = 1);
      setTheme(ThemeMode.values[Prefs.themeMode]);
      loadConfig();
      if (Prefs.numRuns < 1)
        Smartlook.setupAndStartRecording(SetupOptionsBuilder('6488995bc0e02e3d4defab25862fd68ebf40a071').build());
    });

    Wakelock.disable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: <NavigatorObserver>[observer],
      // title: 'Title Example',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: supportedLocales,
      locale: locale,
      theme: Themes.data,
      darkTheme: Themes.darkData,
      themeMode: themeMode,
      home: preparedPage(),
    );
  }

  Widget preparedPage() {
    switch (loadingState) {
      case 1:
        return waitingPage!;
      case 2:
        return IndexPage();
      default:
        return SizedBox();
    }
  }

  void setTheme(ThemeMode mode) {
    if (themeMode == mode) return;
    themeMode = mode;
    Prefs.instance.setInt("themeMode", mode.index);
    setState(() {});
  }

  void setLocale(String lang) {
    var _loc = supportedLocales.firstWhere((l) => l.languageCode == lang,
        orElse: () => supportedLocales[0]);
    setState(() {
      locale = _loc;
      Prefs.instance.setString("locale", lang);
    });
  }

  void loadConfig() {
    Configs.create(() {
      if (waitingPage!.page!.state > 1)
        waitingPage!.page!.end(() {
          setState(() => loadingState = 2);
        });
      else
        setState(() => loadingState = 2);
    }, (e) => waitingPage!.page!.error(loadConfig));
  }
}
