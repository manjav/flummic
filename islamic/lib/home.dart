import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  String title = "Sura 1";
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
      fontFamily: 'Uthmani', fontSize: 22, height: 2, letterSpacing: 2);
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title, style: textStyle),
      ),
    ));
  }
}
