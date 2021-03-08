import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islamic/models.dart';
import 'package:islamic/utils.dart';
import 'package:islamic/waiting.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<MyApp> {
  bool configured = false;
  @override
  void initState() {
    super.initState();
    if (!configured)
      Configs.create(() {
        print(Configs.instance.translators[0].data[0][4]);
        configured = true;
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Title Example',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en", ""),
        const Locale("fa", ""),
      ],
      locale: Locale(Utils.getLocaleByTimezone(Utils.findTimezone()), ""),
      // debugShowCheckedModeBanner: false,
      // theme: ThemeData(primarySwatch: Colors.blue),
      home: configured ? HomePage() : WaitingPage(),
    );
  }
}
