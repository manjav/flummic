import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islamic/pages/index.dart';
import 'package:islamic/pages/wizard.dart';
import 'package:wakelock/wakelock.dart';

import 'models.dart';
import 'pages/waiting.dart';
import 'utils/themes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  static int? t;
  static final supportedLocales = [
    const Locale("ar", ""),
    const Locale("de", ""),
    const Locale("en", ""),
    const Locale("es", ""),
    const Locale("fa", ""),
    const Locale("fr", ""),
    const Locale("hi", ""),
    const Locale("id", ""),
    const Locale("ml", ""),
    const Locale("ru", ""),
    const Locale("tr", ""),
    const Locale("ur", "")
  ];

  const MyApp({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<MyApp> {
  var loadingState = 0;
  static final analytics = FirebaseAnalytics.instance;
  static final observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    Settings.instance.addListener(() => setState(() {}));
    Configs.instance.addListener(() {
      if (Configs.instance.state == LoadState.finalized) _gotoWizard();
    });
    Wakelock.disable();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [observer],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: MyApp.supportedLocales,
      locale: Settings.instance.locale,
      theme: Themes.data,
      darkTheme: Themes.darkData,
      themeMode: Settings.instance.themeMode,
      home: _preparedPage(),
    );
  }

  Widget _preparedPage() {
    switch (loadingState) {
      case 0:
        return const WaitingPage();
      case 2:
        return WizardPage(onComplete: _onWizardComplete);
      case 3:
        return const IndexPage();
      default:
        return const SizedBox();
    }
  }

  void _gotoWizard() {
    loadingState = Prefs.numRuns < 3 && Prefs.needWizard ? 2 : 3;
    setState(() {});
  }

  void _onWizardComplete() {
    Prefs.instance.setBool("needWizard", false);
    setState(() => loadingState = 3);
  }
}
