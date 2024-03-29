import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:islamic/main.dart';
import 'package:islamic/models.dart';
import 'package:islamic/pages/persons.dart';
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
  final _items = [Icons.language, Icons.brightness_medium, Icons.translate];
  final _pageController = PageController();

  int _page = 0;
  int _selectedText = 0;
  final _texts = [
    "ذٰلِكَ الكِتـٰبُ لا رَيبَ ۛ فيهِ ۛ هُدًى لِلمُتَّقينَ",
    "<u>Tha</u>lika alkit<u>a</u>bu l<u>a</u> rayba feehi hudan lilmuttaqeen<b>a</b>"
  ];
  final _fonts = ["mequran", "scheherazade"];

  AppState? _app;
  ThemeData? _theme;
  TextStyle? _quranStyle;
  List<Person> _qurans = <Person>[];
  List<Person> _otherTexts = <Person>[];

  AnimationController? _finalAnimation;
  AnimationController? _buttonsAnimation;
  AnimationController? _progressAnimation;
  double get progress => (_page + 1) / (_items.length + 1);

  @override
  void initState() {
    super.initState();
    _progressAnimation = AnimationController(vsync: this, value: progress);
    _progressAnimation!.addListener(() => setState(() {}));

    _buttonsAnimation = AnimationController(vsync: this, upperBound: 2);
    _buttonsAnimation!.addListener(() => setState(() {}));

    _finalAnimation = AnimationController(vsync: this, upperBound: 10);
    _finalAnimation!.addListener(() => setState(() {}));

    Future.delayed(const Duration(seconds: 3), _updateButtons);
  }

  @override
  Widget build(BuildContext context) {
    _app = MyApp.of(context);
    _theme = Theme.of(context);
    _quranStyle = TextStyle(
        fontFamily: Prefs.font,
        fontSize: 18 * Prefs.textScale,
        height: 2.2,
        color: _theme!.textTheme.bodyText1!.color);
    var r = Localization.isRTL;
    return Scaffold(
        body: Stack(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _header(),
          _divider(),
          _slides(),
          SizedBox(height: 48)
        ],
      ),
      _circlaButton(
          _page >= _items.length - 1 ? Icons.check : Icons.arrow_forward,
          56,
          r ? null : 24,
          r ? 24 : null),
      _circlaButton(Icons.arrow_back, 40, r ? 28 : null, r ? null : 28),
      _finishOverley()
    ]));
  }

  Widget _header() {
    return Container(
        color: _theme!.appBarTheme.backgroundColor,
        height: 120,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              Text("wiz_$_page".l(), style: _theme!.textTheme.headline5),
            ]));
  }

  Widget _divider() {
    return Container(
        height: 4,
        child: Stack(alignment: Alignment.center, children: [
          LinearProgressIndicator(
            minHeight: 4,
            backgroundColor: _theme!.textSelectionTheme.selectionColor,
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
                color: i > _page
                    ? _theme!.textSelectionTheme.selectionColor
                    : _theme!.accentColor,
                shape: BoxShape.circle),
            child: Icon(_items[i],
                color: i > _page
                    ? _theme!.iconTheme.color
                    : _theme!.backgroundColor)));
  }

  Widget _circlaButton(
      IconData icon, double size, double? right, double? left) {
    var dir = icon == Icons.arrow_back ? -1 : 1;
    if (_page == 0 && dir == -1) return SizedBox();
    double s =
        size * (_buttonsAnimation!.value - (dir == 1 ? 0 : 1)).clamp(0, 1);
    return Positioned(
        bottom: right ?? left,
        right: right,
        left: left,
        width: size,
        height: size,
        child: Container(
            alignment: Alignment.center,
            child: Container(
                width: s,
                height: s,
                alignment: Alignment.center,
                child: FloatingActionButton(
                    backgroundColor:
                        dir == 1 ? _theme!.buttonColor : _theme!.focusColor,
                    child: Icon(icon, size: s * 0.5),
                    onPressed: () {
                      if (_page + dir >= _items.length) {
                        _finalAnimation!
                            .animateTo(10, duration: const Duration(seconds: 6))
                            .whenComplete(() => widget.onComplete.call());
                        return;
                      }
                      _pageController.animateToPage(_page + dir,
                          duration: Duration(milliseconds: 600),
                          curve: Curves.easeInOutSine);
                    }))));
  }

  void _updateButtons() {
    _buttonsAnimation!.value = 0;
    _buttonsAnimation!.animateTo(2,
        duration: Duration(milliseconds: 1500), curve: Curves.easeOutBack);
  }

  Widget _slides() {
    return Expanded(
      child: PageView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: _items.length,
          controller: _pageController,
          itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.fromLTRB(24, 48, 24, 36),
              child: i == 0 ? _slide_0() : (i == 1 ? _slide_1() : _slide_2())),
          onPageChanged: (int index) {
            var p = index.round();
            if (_page != p) {
              _page = p;
              _progressAnimation!.animateTo(progress,
                  duration: Duration(seconds: 1), curve: Curves.easeOutExpo);
              _updateButtons();
            }
          }),
    );
  }

  Widget _slide_0() {
    var aya = 18;
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _container(children: [
        Texts.title("select_loc".l(), _theme!),
        DropdownButton<Locale>(
          isExpanded: true,
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
                          alignment: Alignment.center,
                          child: Text(
                            value.languageCode.f(),
                            textDirection: TextDirection.ltr,
                            // style: _theme!.textTheme.subtitle2,
                          ))))
              .toList(),
        )
      ]),
      // SizedBox(height: 16),
      _container(children: [
        Texts.title("wiz_quran".l(), _theme!),
        ButtonGroup(
            (String title, int index) {
              return Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: index == 0
                      ? Texts.quran("۞ ", _texts[0],
                          "   ﴿${(aya + 1).toArabic()}﴾ ", _quranStyle)
                      : HtmlWidget(
                          "<p align=\"justify\" dir=\"ltr\"> ۞ ${_texts[1]} (${(aya + 1).n()}) </p>",
                          textStyle: _theme!.textTheme.headline6));
            },
            items: _texts,
            buttonSize: 132,
            showSelection: true,
            current: _selectedText,
            selectColor: _theme!.cardColor,
            deselectColor: _theme!.backgroundColor,
            onTab: (_selected) {
              setState(() {
                _selectedText = _selected;
                Prefs.removePerson(PType.text, "all");
                var ts = ["ar.uthmanimin", "en.transliteration"];
                Configs.instance.texts[ts[_selected]]!.select(_updateButtons);
              });
            })
      ]),
    ]);
  }

  Widget _slide_1() {
    var aya = 18;
    var isLight = Prefs.themeMode == 1;
    if (Prefs.themeMode == 0)
      isLight = MediaQuery.of(context).platformBrightness == Brightness.light;
    return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      LiteRollingSwitch(
        //initial value
        value: isLight,
        textOn: "theme_${1}".l(),
        textOff: "theme_${2}".l(),
        colorOn: _theme!.buttonColor,
        colorOff: _theme!.buttonColor,
        iconOn: Icons.wb_sunny,
        iconOff: Icons.nightlight_round,
        textSize: 16.0,
        onChanged: (bool state) =>
            _app!.setTheme(ThemeMode.values[state ? 1 : 2]),
      ),
      _container(children: [
        Texts.title("select_font".l(), _theme!),
        ButtonGroup(
          (String title, int index) {
            return Padding(
                padding: EdgeInsets.only(left: 24),
                child: Texts.quran(
                    "۞ ",
                    _texts[0],
                    " ﴿${(aya + 1).toArabic()}﴾ ",
                    TextStyle(
                        fontFamily: _fonts[index],
                        fontSize: 18,
                        height: 2.2,
                        color: _theme!.textTheme.bodyText1!.color)));
          },
          items: _fonts,
          buttonSize: 132,
          showSelection: true,
          current: _fonts.indexOf(Prefs.font),
          selectColor: _theme!.cardColor,
          deselectColor: _theme!.backgroundColor,
          onTab: (_selected) {
            Prefs.instance.setString("font", _fonts[_selected]);
            _updateButtons();
          },
        )
      ])
    ]);
  }

  Widget _slide_2() {
    _qurans = <Person>[];
    _otherTexts = <Person>[];
    for (var path in Prefs.persons[PType.text]!) {
      var p = Configs.instance.texts[path];
      p!.mode == "quran_t" ? _qurans.add(p) : _otherTexts.add(p);
    }

    return ListView.builder(
        padding: EdgeInsets.all(4),
        itemCount: 1,
        itemBuilder: (context, i) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _textsProvider(1, 1));
        });
  }

  List<Widget> _textsProvider(int sura, int aya) {
    var rows = <Widget>[];
    var i = 0;
    for (var p in _qurans) {
      var t = p.data![sura][aya];
      var hizbFlag = Texts.getHizbFlag(sura + 1, aya + 1, i);
      if (p.path == "ar.uthmanimin")
        rows.add(Texts.quran(hizbFlag, t, "    ﴿${(aya + 1).toArabic()}﴾",
            _quranStyle, TextAlign.center));
      else {
        rows.add(p.path == "en.transliteration"
            ? HtmlWidget(
                "<p align=\"justify\" dir=\"ltr\"> $t (${aya + 1}) </p>",
                textStyle: _theme!.textTheme.headline6)
            : Text("$t (${(aya + 1).n()}) ",
                style: _theme!.textTheme.headline6,
                textAlign: TextAlign.justify));
      }
      ++i;
    }

    for (var t in _otherTexts) {
      rows.add(SizedBox(height: 24));
      var dir =
          Bidi.isRtlLanguage(t.flag) ? TextDirection.rtl : TextDirection.ltr;
      var no = i < 1 ? (aya + 1).n(t.flag) : '';
      if (dir == TextDirection.rtl) no = no.split('').reversed.join();
      if (no.length > 0) no += '. ';
      var text =
          "${dir == TextDirection.rtl ? '\u202E' : ''}\t\t\t\t\t\t\t $no${t.data![sura][aya]}";
      rows.add(Stack(
        textDirection: dir,
        children: [
          Text("$text",
              textAlign: TextAlign.justify,
              textDirection: dir,
              style: _theme!.textTheme.caption),
          Avatar(t.path!, 15)
        ],
      ));
      ++i;
    }
    rows.add(SizedBox(height: 24));
    rows.add(GestureDetector(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_circle_outline,
              color: _theme!.textTheme.bodyText1!.color),
          SizedBox(width: 16),
          Text("add_translate".l())
        ]),
        onTap: _addPerson));
    return rows;
  }

  void _addPerson() async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PersonListPage(PType.text, "trans_t", Configs.instance.texts)));
    setState(() {});
  }

  _finishOverley() {
    if (_finalAnimation!.value <= 0) return SizedBox();
    double color = (_finalAnimation!.value < 3
            ? _finalAnimation!.value - 2
            : (10 - _finalAnimation!.value) * 0.5)
        .clamp(0, 1);
    return Opacity(
        opacity: _finalAnimation!.value.clamp(0, 1),
        child: Container(
            color: _theme!.backgroundColor,
            alignment: Alignment.center,
            child: Text("\n${String.fromCharCode(194)}",
                style: TextStyle(
                    fontFamily: 'Titles',
                    fontSize: 44,
                    color: Color.lerp(Colors.transparent,
                        _theme!.textTheme.bodyText1!.color, color)))));
  }

  Widget _container({List<Widget>? children}) {
    return Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: _theme!.cardColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.all(Radius.circular(16))),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: children ?? []));
  }
}
