import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:islamic/pages/search.dart';
import 'package:islamic/widgets/player.dart';
import 'package:islamic/widgets/popup.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models.dart';
import '../pages/persons.dart';
import '../utils/localization.dart';
import '../buttons.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _toolbarHeight = 56.0;
  ScrollablePositionedList ayaList;
  PageController suraPageController;
  TextStyle suraStyle = TextStyle(
    fontFamily: 'SuraNames',
    fontSize: 32,
  );
  TextStyle uthmaniStyle;
  int selectedSura = 0;
  int selectedAya = 0;
  double toolbarHeight;
  double startScrollBarIndicator = 0;
  bool hasQuranText = false;
  ThemeData theme;
  AppState app;

  void initHome() {
    selectedSura = Prefs.selectedSura;
    selectedAya = Prefs.selectedAya;
    hasQuranText = Prefs.persons[PType.text].indexOf("ar.uthmanimin") > -1;
    if (suraPageController != null) return;

    toolbarHeight = _toolbarHeight;
    suraPageController =
        PageController(keepPage: true, initialPage: selectedSura);
    suraPageController.addListener(() {
      var page = suraPageController.page.round();
      if (page != selectedSura) {
        setState(() {
          Prefs.selectedSura = page;
          toolbarHeight = _toolbarHeight;
        });
      }
    });

    app = MyApp.of(context);
    if (app.player == null) app.player = Player();
    app.player.onStateChange = playerOnStateChange;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedAya > 0) gotoAya(selectedAya, 1200);
    });
  }

  @override
  Widget build(BuildContext context) {
    initHome();
    theme = Theme.of(context);
    uthmaniStyle = TextStyle(
        fontFamily: 'Uthmani',
        fontSize: 20,
        height: 2,
        wordSpacing: 2,
        color: theme.textTheme.bodyText1.color);

    var queryData = MediaQuery.of(context);
    return MediaQuery(
        data: queryData.copyWith(
            textScaleFactor: queryData.textScaleFactor * Prefs.textScale),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
                appBar: AppBar(
                    elevation: 0,
                    actions: Localization.isRTL
                        ? [getButton("forward")]
                        : [getButton("search"), getButton("settings")],
                    leading: Localization.isRTL
                        ? Row(children: [
                            getButton("settings"),
                            getButton("search")
                          ])
                        : getButton("back"),
                    leadingWidth: _toolbarHeight * (Localization.isRTL ? 2 : 1),
                    automaticallyImplyLeading: false),
                body: Stack(
                  children: [
                    PageView.builder(
                        reverse: true,
                        itemCount: Configs.instance.metadata.suras.length,
                        itemBuilder: suraPageBuilder,
                        controller: suraPageController),
                    Transform.translate(
                        offset: Offset(0, -_toolbarHeight + toolbarHeight),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 6.0, // changes position of shadow
                              ),
                            ],
                          ),
                          child: Text(String.fromCharCode(selectedSura + 13),
                              style: suraStyle),
                          height: _toolbarHeight,
                        )),
                    footer()
                  ],
                ))));
  }

  Widget suraPageBuilder(BuildContext context, int p) {
    var len = Configs.instance.metadata.suras[p].ayas;
    selectedAya = Prefs.selectedSura == selectedSura ? Prefs.selectedAya : 0;
    return ayaList = ScrollablePositionedList.builder(
      initialAlignment: 0.15,
      itemScrollController: ItemScrollController(),
      itemPositionsListener: ItemPositionsListener.create(),
      padding: EdgeInsets.only(top: _toolbarHeight, bottom: 48),
      itemCount: len,
      itemBuilder: (BuildContext ctx, i) => ayaItemBuilder(p, i),
      onScroll: onPageScroll,
    );
  }

  void onPageScroll(ScrollPosition position) {
    if (position.pixels < 122) return;
    var changes = startScrollBarIndicator - position.pixels;
    startScrollBarIndicator = position.pixels;
    var h = (toolbarHeight + changes).clamp(0.0, _toolbarHeight);
    if (toolbarHeight != h) {
      toolbarHeight = h;
      setState(() {});
    }
  }

  Widget ayaItemBuilder(int position, int index) {
    var color = index % 2 == 0 ? theme.backgroundColor : theme.cardColor;
    return Stack(children: [
      Container(
          color: index == selectedAya ? theme.focusColor : color,
          child: GestureDetector(
              onTap: () => setState(() {
                    // var tween = Tween<double>(begin: -200, end: 0);
                    toolbarHeight = _toolbarHeight;
                  }),
              onLongPress: () => showAyaDetails(position, index),
              child: Padding(
                  padding:
                      EdgeInsets.only(top: 16, right: 16, bottom: 5, left: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: textsProvider(position, index))))),
      Prefs.getNote(position, index) == null
          ? SizedBox()
          : Positioned(
              top: -2,
              left: 8,
              child: Icon(
                Icons.bookmark_sharp,
                size: 14,
                color: theme.textTheme.caption.color,
              )),
      Positioned(
          top: -8,
          right: -14,
          child: IconButton(
            icon: Icon(Icons.more_vert,
                size: 16, color: theme.textTheme.caption.color),
            onPressed: () => showAyaDetails(position, index),
          )),
    ]);
  }

  void showAyaDetails(int position, int index) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: theme.dialogBackgroundColor,
      context: context,
      builder: (context) => AyaDetails(position, index, () => setState(() {})),
    ).then((value) {
      setState(() {});
    });
  }

  List<Widget> textsProvider(int sura, int aya) {
    var rows = <Widget>[];
    if (aya == 0 && sura != 0 && sura != 8) {
      rows.add(SizedBox(height: 50));
      rows.add(Text(
        "",
        style: suraStyle,
        textAlign: TextAlign.center,
      ));
      rows.add(SizedBox(height: 40));
    }

    rows.add(SizedBox(height: 16));
    if (hasQuranText) {
      var hizbFlag = getHizbFlag(sura + 1, aya + 1);
      rows.add(Text(
          "$hizbFlag ${Configs.instance.quran[sura][aya]} ﴿${(aya + 1).toArabic()}﴾",
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          style: uthmaniStyle));
    }

    for (var path in Prefs.persons[PType.text]) {
      if (path == "ar.uthmanimin") continue;
      var texts = Configs.instance.texts[path];
      var dir = Bidi.isRtlLanguage(texts.flag)
          ? TextDirection.rtl
          : TextDirection.ltr;
      rows.add(Stack(
        textDirection: dir,
        children: <Widget>[
          Text(
              rows.length < 1
                  ? "\t\t\t\t\t\t\t\t\t${(aya + 1).n(texts.flag)}. ${texts.data[sura][aya]}"
                  : "\t\t\t\t\t\t\t\t\t${texts.data[sura][aya]}",
              textAlign: TextAlign.justify,
              textDirection: dir,
              style: theme.textTheme.caption),
          Avatar(path, 15)
        ],
      ));
    }
    return rows;
  }

  String getHizbFlag(int sura, int aya) {
    var hizbs = Configs.instance.metadata.hizbs;
    var len = hizbs.length;
    for (var i = 0; i < len; i++) {
      if (hizbs[i].sura > sura) return "";
      if (hizbs[i].sura == sura && hizbs[i].aya == aya) return "۞";
    }
    return "";
  }

  Widget footer() {
    if (app.player == null) return Container();
    var coef = (_toolbarHeight - toolbarHeight);
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            transform: Matrix4.identity()..translate(0.001, coef * 0.4),
            height: 56,
            child: Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                    top: 0,
                    bottom: 0,
                    child: Opacity(
                        opacity: toolbarHeight / _toolbarHeight,
                        child: getButton("texts"))),
                Positioned(
                    top: 0,
                    bottom: 0,
                    left: 48,
                    child: Opacity(
                        opacity: toolbarHeight / _toolbarHeight,
                        child: getButton("sounds"))),
                Positioned(
                    top: 10 - coef * 0.11,
                    right: 86 - coef * 0.4,
                    child: Avatar(app.player.sound.path, 20 - coef * 0.12)),
                Positioned(
                    top: 10 - coef * 0.2,
                    right: 132 - coef * 0.65,
                    child: Text(
                      app.player.sound.name,
                      style: theme.textTheme.bodyText2,
                      textAlign: TextAlign.right,
                    )),
                Positioned(
                    top: -_toolbarHeight * 0.5 + coef * 0.15,
                    right: _toolbarHeight * 0.5 - coef * 0.15,
                    child: SizedBox(
                        height: _toolbarHeight * 0.7 + toolbarHeight * 0.3,
                        width: _toolbarHeight * 0.7 + toolbarHeight * 0.3,
                        child: FloatingActionButton(
                            child: Icon(getIcon()),
                            onPressed: onTogglePressed)))
              ],
            ),
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            )));
  }

  Future<void> footerPressed(PType type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonPage(type)),
    );
    setState(() {});
  }

  Future<void> playerOnStateChange(AudioPlayerState state) async {
    setState(() {});
    if (state != AudioPlayerState.PLAYING) return;
    goto(app.player.sura, app.player.aya);
  }

  void goto(int sura, int aya) {
    if (sura != selectedSura) {
      var dis = (sura - selectedSura).abs();
      gotoSura(sura, dis > 3 ? 0 : 400);
      // gotoAya(aya, 0);
    } else {
      gotoAya(aya, 800);
    }
    Prefs.selectedSura = selectedSura = sura;
    Prefs.selectedAya = selectedAya = aya;
    setState(() {});
    // print("sura ${player.sura} aya ${player.aya} index ${player.index}");
  }

  void gotoSura(int sura, int duration) {
    if (duration == 0)
      suraPageController.jumpToPage(sura);
    else
      suraPageController.animateToPage(sura,
          duration: Duration(milliseconds: duration), curve: Curves.easeInOut);
  }

  void gotoAya(int aya, int duration) {
    print("aya $aya, duration $duration");
    if (duration == 0) {
      ayaList.itemScrollController.jumpTo(index: aya);
    } else {
      ayaList.itemScrollController.scrollTo(
          index: aya,
          duration: Duration(milliseconds: duration),
          curve: Curves.easeInOut);
    }
  }

  IconData getIcon() {
    switch (app.player.playerState) {
      case AudioPlayerState.PLAYING:
        return Icons.pause;
      default:
        return Icons.play_arrow;
    }
  }

  void onTogglePressed() {
    if (app.player.sura == null)
      app.player.select(selectedSura, selectedAya, 0, true);
    else
      app.player.toggle();
  }

  IconButton getButton(String type) {
    switch (type) {
      case "settings":
        return IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => showModalBottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: theme.dialogBackgroundColor,
            context: context,
            builder: (context) => Settings(() => setState(() {})),
          ),
        );
      case "search":
        return IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                ));
      case "forward":
      case "back":
        return IconButton(
          icon: Icon(type == "back" ? Icons.arrow_back : Icons.arrow_forward),
          onPressed: () => Navigator.pop(context),
        );
      case "texts":
        return IconButton(
            icon: Icon(Icons.add_comment_outlined,
                color: theme.appBarTheme.iconTheme.color),
            onPressed: () => footerPressed(PType.text));
      default:
        return IconButton(
            icon: Icon(Icons.headset_sharp,
                color: theme.appBarTheme.iconTheme.color),
            onPressed: () => footerPressed(PType.sound));
    }
  }
}
