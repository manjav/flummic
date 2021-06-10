import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islamic/main.dart';
import 'package:islamic/utils/localization.dart';

class WizardPage extends StatefulWidget {
  WizardPage({Key? key}) : super(key: key);

  @override
  _WizardPageState createState() => _WizardPageState();
}

class _WizardPageState extends State<WizardPage> with TickerProviderStateMixin {
  final _items = [
    Icons.language,
    Icons.visibility,
    Icons.text_format,
    Icons.translate
  ];
  final _pageController = PageController();
  AnimationController? _progressAnimation;

  int _page = 0;

  ThemeData? _theme;
  AppState? _app;
  @override
  void initState() {
    super.initState();
    _progressAnimation =
        AnimationController(vsync: this, value: 1 / (_items.length + 1));
    _progressAnimation!.addListener(() => setState(() {}));
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
        child: Stack(alignment: Alignment.center, children: [
          LinearProgressIndicator(
            minHeight: 4,
            backgroundColor: Colors.teal[900],
            value: _progressAnimation!.value,
          ),
        ])
        );
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
            _progressAnimation!.animateTo((index + 1) / (_items.length + 1),
                duration: Duration(seconds: 1), curve: Curves.easeOutExpo);
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
