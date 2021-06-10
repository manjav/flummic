import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islamic/main.dart';
import 'package:islamic/utils/localization.dart';

class WizardPage extends StatefulWidget {
  WizardPage({Key? key}) : super(key: key);

  @override
  _WizardPageState createState() => _WizardPageState();
}

  final _items = [
    Icons.language,
    Icons.visibility,
    Icons.text_format,
    Icons.translate
  ];
  final _pageController = PageController();
  int _page = 0;

  ThemeData? _theme;
  AppState? _app;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _app = MyApp.of(context);
    _theme = Theme.of(context);
    var r = Localization.isRTL;
    return Scaffold(
        body: Stack(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[_header(), _divider(), _slides()],
      ),
    ]));
  }

  Widget _header() {
    return Container(
        height: 200);
  }

  Widget _divider() {
    return Container(
        height: 4,
        );
  }

  Widget _slides() {
    return Expanded(
      child: PageView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          controller: _pageController,
          itemBuilder: _pageItemBuilder,
          onPageChanged: (int index) {
            _page = index;
          }),
    );
  }

  Widget _pageItemBuilder(BuildContext context, int index) {
    return Stack(
      alignment: Alignment.center,
      children: [
          Center(child: FlutterLogo(size: 200.0))
      ],
    );
  }
}
