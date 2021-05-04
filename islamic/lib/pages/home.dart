import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:islamic/pages/search.dart';
import 'package:islamic/utils/player.dart';
import 'package:islamic/widgets/popup.dart';
import 'package:islamic/widgets/texts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../buttons.dart';
import '../models.dart';
import '../pages/persons.dart';
import '../utils/localization.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static int selectedPage = 0;
  static int selectedIndex = 0;
  final _toolbarHeight = 56.0;
  ScrollablePositionedList? ayaList;
  PageController? suraPageController;
  TextStyle headerStyle = TextStyle(
    fontFamily: Prefs.naviMode == "sura" ? 'Titles' : null,
    fontSize: Prefs.naviMode == "sura" ? 32 : 18,
  );
  AnimationController? headerAnimation;
  TextStyle titlesStyle =
      TextStyle(fontFamily: 'Titles', fontSize: 28, letterSpacing: -4);
  TextStyle? uthmaniStyle;
  // int selectedSura = 0;
  // int selectedAya = 0;
  double toolbarHeight = 56;
  double startScrollBarIndicator = 0;
  bool hasQuranText = false;
  Person playingSound =
      Configs.instance.sounds[Prefs.persons[PType.sound]![0]]!;
  late ThemeData theme;
  bool isPlaying = false;
  static int soundState = 0;

  void initHome() {
    hasQuranText = Prefs.persons[PType.text]!.indexOf("ar.uthmanimin") > -1;

    theme = Theme.of(context);
    uthmaniStyle = TextStyle(
        fontFamily: Prefs.font,
        fontSize: 20,
        height: 2,
        color: theme.textTheme.bodyText1!.color);
    Texts.teal =
        TextStyle(color: theme.textSelectionTheme.selectionHandleColor);
    if (suraPageController != null) return;
    initAudio();

    suraPageController =
        PageController(keepPage: true, initialPage: selectedPage);
    suraPageController!.addListener(() {
      var page = suraPageController!.page!.round();
      if (selectedPage != page) {
        setState(() {
          selectedPage = page;
          // var res = Configs.instance.pageItems[page][0];
          // Prefs.selectedSura = res.sura;
          // Prefs.selectedAya = res.aya;
          toolbarHeight = _toolbarHeight;
        });
      }
    });
    headerAnimation = AnimationController(
        duration: const Duration(milliseconds: 500), value: 1, vsync: this);
    headerAnimation!.addListener(() {
      toolbarHeight = headerAnimation!.value * _toolbarHeight;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    initHome();
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
                        itemCount: Configs.instance.pageItems.length,
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
                            child: Text(headerTextProvider(),
                                style: !Localization.isRTL &&
                                        Prefs.naviMode == "page"
                                    ? theme.textTheme.subtitle1
                                    : titlesStyle),
                            height: _toolbarHeight)),
                    footer()
                  ],
                ))));
  }

  String headerTextProvider() {
    if (Prefs.naviMode == "sura")
      return "${String.fromCharCode(selectedPage + 204)}${String.fromCharCode(192)}";
    if (Prefs.naviMode == "juze")
      return "${String.fromCharCode(selectedPage + 327)}${String.fromCharCode(193)}";
    return (selectedPage + 1).n();
  }

  Widget suraPageBuilder(BuildContext context, int p) {
    selectedIndex = selectedPage == p ? selectedIndex : 0;
    ayaList = ScrollablePositionedList.builder(
      initialAlignment: selectedIndex > 0 ? 0.12 : 0,
      initialScrollIndex: selectedIndex,
      itemScrollController: ItemScrollController(),
      itemPositionsListener: ItemPositionsListener.create(),
      padding: EdgeInsets.only(top: _toolbarHeight, bottom: 76),
      itemCount: Configs.instance.pageItems[p].length,
      itemBuilder: (BuildContext ctx, i) => ayaItemBuilder(p, i),
    );
    Future.delayed(Duration(milliseconds: 10), listenScroll);
    return ayaList!;
  }

  void listenScroll() {
    var controller =
        ayaList!.itemScrollController?.of(context)?.primary.scrollController;
    controller?.addListener(() => onPageScroll(controller.position));
  }

  void onPageScroll(ScrollPosition position) {
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
    var part = Configs.instance.pageItems[position][index];
    return GestureDetector(
        onTap: () {
          headerAnimation!.value = toolbarHeight / _toolbarHeight;
          headerAnimation!.animateTo(toolbarHeight > 0.0 ? 0.0 : 1.0,
              curve: Curves.easeOutExpo);
        },
        onLongPress: () => showAyaDetails(part.sura, part.aya),
        child: Stack(children: [
          Container(
              color: index == selectedIndex ? theme.focusColor : color,
              child: Padding(
                  padding:
                      EdgeInsets.only(top: 14, right: 16, bottom: 5, left: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: textsProvider(part.sura, part.aya)))),
          Prefs.getNote(part.sura, part.aya) == null
              ? SizedBox()
              : Positioned(
                  top: -18,
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark_sharp,
                      size: 14,
                      color: theme.textTheme.caption!.color,
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => Generics.editNote(
                              context, theme, part.sura, part.aya, null));
                    },
                  )),
          Positioned(
              top: -8,
              right: -14,
              child: IconButton(
                icon: Icon(Icons.more_vert,
                    size: 16, color: theme.textTheme.caption!.color),
                onPressed: () => showAyaDetails(part.sura, part.aya),
              )),
        ]));
  }

  void showAyaDetails(int sura, int aya) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: theme.dialogBackgroundColor,
      context: context,
      builder: (context) => AyaDetails(sura, aya, (type, data) {
        if (type == "note")
          setState(() {});
        else if (type == "play") play(data);
      }),
    ).then((value) {
      setState(() {});
    });
  }

  List<Widget> textsProvider(int sura, int aya) {
    var rows = <Widget>[];
    if (aya == 0) {
      if (Prefs.naviMode != "sura")
        rows.add(Text(
          "${String.fromCharCode(sura + 204)}${String.fromCharCode(192)}",
          style: titlesStyle,
          textAlign: TextAlign.center,
        ));
      if (sura != 0 && sura != 8)
        rows.add(Text(
          "\n\n${String.fromCharCode(194)}",
          style: titlesStyle,
          textAlign: TextAlign.center,
        ));
      rows.add(SizedBox(height: 40));
    }

    rows.add(SizedBox(height: 16));
    var i = 0;
    if (hasQuranText) {
      var hizbFlag = getHizbFlag(sura + 1, aya + 1);
      rows.add(Texts.quran(hizbFlag, Configs.instance.quran[sura][aya],
          " ﴿${(aya + 1).toArabic()}﴾", uthmaniStyle));
      ++i;
    }

    for (var path in Prefs.persons[PType.text]!) {
      if (path == "ar.uthmanimin") continue;
      var texts = Configs.instance.texts[path];
      var dir = Bidi.isRtlLanguage(texts!.flag)
          ? TextDirection.rtl
          : TextDirection.ltr;
      var no = i < 1 ? (aya + 1).n(texts.flag) : '';
      if (dir == TextDirection.rtl) no = no.split('').reversed.join();
      if (no.length > 0) no += '. ';
      var text =
          "${dir == TextDirection.rtl ? '\u202E' : ''}\t\t\t\t\t\t\t $no${texts.data[sura][aya]}";
      rows.add(Stack(
        textDirection: dir,
        children: [
          texts.path == "en.transliteration"
              ? HtmlWidget(
                  "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$text")
              : Text("$text",
                  textAlign: TextAlign.justify,
                  textDirection: dir,
                  style: theme.textTheme.caption),
          Avatar(path, 15)
        ],
      ));
      ++i;
    }
    return rows;
  }

  String getHizbFlag(int sura, int aya) {
    var hizbs = Configs.instance.metadata.hizbs;
    var len = hizbs.length;
    for (var i = 0; i < len; i++) {
      if (hizbs[i].sura > sura) return "";
      if (hizbs[i].sura == sura && hizbs[i].aya == aya) return "۞ ";
    }
    return "";
  }

  Widget footer() {
    // if (app.player == null) return Container();
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
                    child: Avatar(playingSound.path, 20 - coef * 0.12)),
                Positioned(
                    top: 10 - coef * 0.2,
                    right: 132 - coef * 0.65,
                    child: Text(
                      playingSound.title,
                      style: theme.textTheme.bodyText2,
                      textAlign: TextAlign.right,
                    )),
                Positioned(
                    top: -_toolbarHeight * 0.5 + coef * 0.15,
                    right: _toolbarHeight * 0.5 - coef * 0.15,
                    child: SizedBox(
                        height: _toolbarHeight * 0.7 + toolbarHeight * 0.3,
                        width: _toolbarHeight * 0.7 + toolbarHeight * 0.3,
                        child: getToggleButton(context)))
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
    updatePlayer();
    setState(() {});
  }

  void goto(int sura, int aya) {
    var part = Configs.instance.getPart(sura, aya);
    var page = part[0];
    var index = part[1];
    if (page != selectedPage) {
      var dis = (page - selectedPage).abs();
      gotoPage(page, dis > 3 ? 0 : 400);
      // gotoAya(aya, 0);
    } else {
      gotoIndex(index, 800);
    }
    // Prefs.selectedSura = selectedSura = sura;
    // Prefs.selectedAya = selectedAya = aya;
    selectedIndex = index;
    setState(() {});
    // print("sura ${player.sura} aya ${player.aya} index ${player.index}");
  }

  void gotoPage(int page, int duration) {
    if (duration == 0)
      suraPageController!.jumpToPage(page);
    else
      suraPageController!.animateToPage(page,
          duration: Duration(milliseconds: duration), curve: Curves.easeInOut);
  }

  void gotoIndex(int index, int duration) {
    print("index $index, duration $duration");
    if (duration == 0) {
      ayaList!.itemScrollController!.jumpTo(index: index);
    } else {
      ayaList!.itemScrollController!.scrollTo(
          index: index,
          duration: Duration(milliseconds: duration),
          curve: Curves.easeInOut);
    }
  }

  Widget getToggleButton(BuildContext context) {
    return StreamBuilder<bool>(
        stream: AudioService.playbackStateStream
            .map((state) => state.playing)
            .distinct(),
        builder: (context, snapshot) {
          isPlaying = snapshot.data ?? false;
          return FloatingActionButton(
              heroTag: "fab",
              child: Icon(getIcon()),
              onPressed: onTogglePressed);
        });
  }

  IconData getIcon() {
    if (soundState == 2) return Icons.access_alarm;
    return isPlaying ? Icons.pause : Icons.play_arrow;
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
                color: theme.appBarTheme.iconTheme!.color),
            onPressed: () => footerPressed(PType.text));
      default:
        return IconButton(
            icon: Icon(Icons.headset_sharp,
                color: theme.appBarTheme.iconTheme!.color),
            onPressed: () => footerPressed(PType.sound));
    }
  }

  Future<void> initAudio() async {
    print("initAudio c ${AudioService.connected} r ${AudioService.running}");
    if (AudioService.connected && AudioService.running) return;

    List<String>? sounds = Prefs.persons[PType.sound];
    playingSound = Configs.instance.sounds[sounds![0]]!;
    setState(() {});
    soundState = 2;
    await AudioService.start(
        backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
        androidNotificationChannelName: 'قرآن هدایت',
        // Enable this if you want the Android service to exit the foreground state on pause.
        //androidStopForegroundOnPause: true,
        androidNotificationColor: Colors.amber.value,
        androidNotificationIcon: 'mipmap/ic_launcher',
        androidEnableQueue: true,
        params: {"ayas": jsonEncode(Configs.instance.navigations["all"]![0])});
    updatePlayer();
    soundState = 0;
    setState(() {});

    AudioService.customEventStream.listen((state) {
      var event = json.decode(state as String);
      if (event["type"] == "select") {
        var aya = Configs.instance.navigations["all"]![0][event["data"][0]];
        playingSound = Configs.instance.sounds[sounds[event["data"][1]]]!;
        soundState = 1;
        goto(aya.sura, aya.aya);
      } else if (event["type"] == "stop") {
        soundState = 0;
        setState(() {});
      }
    });
  }

  void onTogglePressed() async {
    await initAudio();
    if (soundState == 1) {
      isPlaying ? AudioService.pause() : AudioService.play();
      return;
    }
    play(Configs.instance.pageItems[selectedPage][0].index);
  }

  void play(int index) async {
    await initAudio();
    AudioService.customAction("select", {"index": index});
  }

  void updatePlayer() {
    var suras = <String>[];
    for (var s in Configs.instance.metadata.suras) suras.add(s.title);
    var sounds = <Person>[];
    for (var p in Prefs.persons[PType.sound]!)
      sounds.add(Configs.instance.sounds[p]!);
    AudioService.customAction(
        "update", {"sounds": jsonEncode(sounds), "suras": suras});
  }
}

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}
