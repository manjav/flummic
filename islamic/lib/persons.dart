import 'package:flutter/material.dart';
class PersonPage extends StatefulWidget {
  String title = "";
  @override
  PersonPageState createState() => PersonPageState();
}


  @override
  void initState() {
    super.initState();
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(AppLocalizations.of(context).translation_title),
          ),
          body:Container(),
        ));
