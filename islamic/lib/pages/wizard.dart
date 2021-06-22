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
  AnimationController? _progressAnimation;

  int _page = 0;
  int _selectedText = -1;
  final _texts = [
    "ذٰلِكَ الكِتـٰبُ لا رَيبَ ۛ فيهِ ۛ هُدًى لِلمُتَّقينَ",
    "<u>Tha</u>lika alkit<u>a</u>bu l<u>a</u> rayba feehi hudan lilmuttaqeen<b>a</b>"
  ];
  final _fonts = ["mequran", "scheherazade"];

  AppState? _app;
  ThemeData? _theme;
  TextStyle? _quranStyle;

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
        child: Text("wiz_$_page".l(), style: _theme!.textTheme.headline5),
        height: 160);
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
                color: i > _page ? _theme!.primaryColor : _theme!.accentColor,
                shape: BoxShape.circle,
                boxShadow: i > _page ? [BoxShadow(blurRadius: 4)] : null),
            child: Icon(_items[i],
                color: i > _page
                    ? _theme!.iconTheme.color
                    : _theme!.backgroundColor)));
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
    return index == 0 ? _slide_0() : (index == 1 ? _slide_1() : _slide_2());
  }

  Widget _circlaButton(
      IconData icon, double size, double? right, double? left) {
    var dir = icon == Icons.arrow_back ? -1 : 1;
    if (dir == 1 && isNextLock) return SizedBox();
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

  bool get isNextLock {
    switch (_page) {
      case 0:
        return Prefs.persons[PType.text]!.isEmpty;
      case 1:
        return Prefs.font.isEmpty;
      default:
        return false;
    }
  }

  Widget _slide_0() {
    var aya = 18;
    return Padding(
        padding: EdgeInsets.all(32),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                                ),
                              ),
                            ))
                    .toList(),
              ),
              SizedBox(height: 72),
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
                buttonSize: 148,
                showSelection: true,
                current: _selectedText,
                selectColor: _theme!.cardColor,
                deselectCOlor: _theme!.backgroundColor,
                onTab: (_selected) {
                  setState(() {
                    _selectedText = _selected;
                      Prefs.removePerson(PType.text, "all");
                    var ts = ["ar.uthmanimin", "en.transliteration"];
                    Configs.instance.texts[ts[_selected]]!
                        .select(() => setState(() {}));
                  });
                  })
            ]));
  }

  Widget _slide_1() {
    var aya = 18;
    var isLight = Prefs.themeMode == 1;
    if (Prefs.themeMode == 0)
      isLight = MediaQuery.of(context).platformBrightness == Brightness.light;
    return Stack(alignment: Alignment.center, children: [
      Positioned(
          bottom: 240,
          left: 32,
          right: 32,
          child: ButtonGroup(
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
            buttonSize: 148,
            showSelection: true,
            current: _fonts.indexOf(Prefs.font),
            selectColor: _theme!.cardColor,
            deselectCOlor: _theme!.backgroundColor,
            onTab: (_selected) {
              setState(() {
                Prefs.instance.setString("font", _fonts[_selected]);
              });
            },
          )),
      Positioned(
          bottom: 140,
          // width: 142,
          child: LiteRollingSwitch(
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
          )),
    ]);
  }

  List<Person> _qurans = <Person>[];
  List<Person> _otherTexts = <Person>[];
  Widget _slide_2() {
    _qurans = <Person>[];
    _otherTexts = <Person>[];
    for (var path in Prefs.persons[PType.text]!) {
      var p = Configs.instance.texts[path];
      p!.mode == "quran_t" ? _qurans.add(p) : _otherTexts.add(p);
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 56, 16, 10),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _textsProvider(1, 1)),
    );
  }

  List<Widget> _textsProvider(int sura, int aya) {
    var rows = <Widget>[];
    var i = 0;
    for (var p in _qurans) {
      var t = p.data![sura][aya];
      var hizbFlag = Texts.getHizbFlag(sura + 1, aya + 1, i);
      if (p.path == "ar.uthmanimin")
        rows.add(Texts.quran(
            hizbFlag, t, "    ﴿${(aya + 1).toArabic()}﴾", _quranStyle));
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
    rows.add(IconButton(
        icon: Icon(Icons.add_circle_outline,
            color: _theme!.textTheme.bodyText1!.color),
        iconSize: 32,
        onPressed: _addPerson));
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
}
