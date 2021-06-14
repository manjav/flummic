import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islamic/main.dart';
import 'package:islamic/models.dart';
import 'package:islamic/utils/localization.dart';
import 'package:islamic/widgets/buttons.dart';
import 'package:islamic/widgets/switch.dart';
import 'package:islamic/widgets/texts.dart';

class WizardPage extends StatefulWidget {
  final Function onComplete;

  WizardPage({Key? key, required this.onComplete}) : super(key: key);

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
  double get progress => (_page + 1) / (_items.length + 1);

  @override
  void initState() {
    super.initState();
    _progressAnimation = AnimationController(vsync: this, value: progress);
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
      _circlaButton(
          _page >= _items.length - 1 ? Icons.check : Icons.arrow_forward,
          56,
          r ? null : 24,
          r ? 24 : null),
      _circlaButton(Icons.arrow_back, 48, r ? 28 : null, r ? null : 28)
    ]));
  }

  Widget _header() {
    return Container(
        color: _theme!.appBarTheme.backgroundColor,
        alignment: Alignment.center,
        child: Text("wiz_$_page", style: _theme!.textTheme.headline6),
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
          FractionallySizedBox(
              widthFactor: 0.94,
              heightFactor: 10,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < _items.length; i++) _indicator(i)
                  ])),
        ]));
  }

  Widget _indicator(int i) {
    double size = i > _page ? 36 : 40;
    return Container(
        alignment: Alignment.center,
        width: 40,
        height: 40,
        child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
                color: i > _page ? _theme!.primaryColor : _theme!.accentColor,
                shape: BoxShape.circle,
                boxShadow: i > _page ? [BoxShadow(blurRadius: 4)] : null),
            child: Icon(_items[i],
                color: i > _page
                    ? _theme!.iconTheme.color
                    : _theme!.primaryColor)));
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
            _progressAnimation!.animateTo(progress,
                duration: Duration(seconds: 1), curve: Curves.easeOutExpo);
          }),
    );
  }

  Widget _pageItemBuilder(BuildContext context, int index) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (index == 0)
          _slideLocale()
        else if (index == 1)
          _slideAppearance()
        else
          Center(child: FlutterLogo(size: 200.0))
      ],
    );
  }

  Widget _circlaButton(
      IconData icon, double size, double? right, double? left) {
    var dir = icon == Icons.arrow_back ? -1 : 1;
    if (_page == 0 && dir == -1) return SizedBox();
    return Positioned(
        bottom: right ?? left,
        right: right,
        left: left,
        width: size,
        height: size,
        child: FloatingActionButton(
            backgroundColor:
                dir == 1 ? _theme!.buttonColor : _theme!.primaryColor,
            child: Icon(icon),
            onPressed: () {
              if (_page + dir >= _items.length) {
                widget.onComplete.call();
                return;
              }
              _pageController.animateToPage(_page + dir,
                duration: Duration(milliseconds: 600),
                  curve: Curves.easeInOutSine);
            }));
  }

  Widget _slideLocale() {
    return Container(
        alignment: Alignment.center,
        child: DropdownButton<Locale>(
          value: _app!.locale,
          style: _theme!.textTheme.caption,
          onChanged: (Locale? v) {
            Localization.change(v!.languageCode, onDone: (l) {
              _app!.setLocale(l);
              setState(() {});
            });
          },
          items: MyApp.supportedLocales
              .map<DropdownMenuItem<Locale>>(
                  (Locale value) => DropdownMenuItem<Locale>(
                        value: value,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value.languageCode.f(),
                            textDirection: TextDirection.ltr,
                            // style: _theme!.textTheme.subtitle2,
                          ),
                        ),
                      ))
              .toList(),
        ));
  }

  Widget _slideAppearance() {
    var aya = 18;
    var uthmaniStyle = TextStyle(
        fontFamily: Prefs.font,
        fontSize: 18 * Prefs.textScale,
        height: 2.2,
        color: _theme!.textTheme.bodyText1!.color);
    var fonts = ["mequran", "scheherazade"];
    var selected = fonts.indexOf(Prefs.font);
    return Stack(alignment: Alignment.center, children: [
      Positioned(
          top: 72,
          left: 32,
          right: 32,
          height: 200,
          child: Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _theme!.cardColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Texts.quran("۞ ", Configs.instance.quran[2][aya],
                  " ﴿${(aya + 1).toArabic()}﴾ ", uthmaniStyle))),
      Positioned(
          bottom: 240,
          left: 32,
          right: 32,
          child: ButtonGroup(
            titles: ["mequran".l(), "scheherazade".l()],
            current: selected,
            color: _theme!.primaryColor,
            secondaryColor: _theme!.accentColor,
            onTab: (_selected) {
              setState(() {
                selected = _selected;
                Prefs.instance.setString("font", fonts[selected]);
              });
            },
          )),
      Positioned(
          bottom: 140,
          // width: 142,
          child: LiteRollingSwitch(
            //initial value
            value: true,
            textOn: "theme_${1}".l(),
            textOff: "theme_${2}".l(),
            colorOn: _theme!.buttonColor,
            colorOff: _theme!.buttonColor,
            iconOn: Icons.wb_sunny,
            iconOff: Icons.nightlight_round,
            textSize: 16.0,
            onChanged: (bool state) {
              _app!.setTheme(ThemeMode.values[state ? 1 : 2]);
            },
          )),
    ]);
  }
}
