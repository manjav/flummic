import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:islamic/pages/search.dart';
import 'package:islamic/utils/utils.dart';
import 'package:islamic/widgets/popup.dart';
import 'package:islamic/widgets/texts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakelock/wakelock.dart';

import '../models.dart';
import '../pages/persons.dart';
import '../utils/localization.dart';
import '../widgets/buttons.dart';

class HomePage extends StatefulWidget {
  final AudioHandler audioHandler;
  const HomePage(this.audioHandler, {Key? key}) : super(key: key);
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  static int selectedPage = 0;
  static int selectedIndex = 0;
  final _toolbarHeight = 56.0;
  double toolbarHeight = 56;
  int scrollIndex = 0;
  ScrollablePositionedList? ayaList;
  PageController? suraPageController;
  TextStyle headerStyle = TextStyle(
    fontFamily: Prefs.naviMode == "sura" ? 'Titles' : null,
    fontSize: Prefs.naviMode == "sura" ? 32 : 18,
  );
  AnimationController? headerAnimation;
  TextStyle titlesStyle =
      const TextStyle(fontFamily: 'Titles', fontSize: 28, letterSpacing: -4);
  TextStyle? uthmaniStyle;
  List<Person> _qurans = <Person>[];
  List<Person> _otherTexts = <Person>[];
  Person playingSound =
      Configs.instance.sounds[Prefs.persons[PType.sound]![0]]!;
  Aya playingAya = Aya(0, 0, 0);
  ThemeData? _theme;

  bool _disposed = false;
  ThemeData get theme => _theme!;
  static SoundState soundState = SoundState.stop;

  void initHome() {
    _qurans = <Person>[];
    _otherTexts = <Person>[];
    for (var path in Prefs.persons[PType.text]!) {
      var p = Configs.instance.texts[path];
      p!.mode == "quran_t" ? _qurans.add(p) : _otherTexts.add(p);
    }

    _theme = Theme.of(context);
    uthmaniStyle = TextStyle(
        fontFamily: Prefs.font,
        fontSize: 18 * Prefs.textScale,
        height: 2.2,
        color: theme.textTheme.bodyLarge!.color);
    Texts.teal =
        TextStyle(color: theme.textSelectionTheme.selectionHandleColor);
    if (suraPageController != null) return;
    Utils.wakeup(context);
    initAudio();

    suraPageController =
        PageController(keepPage: true, initialPage: selectedPage);
    playingAya.sura = Configs.instance.pageItems[selectedPage][0].sura;
    suraPageController!.addListener(() {
      var page = suraPageController!.page!.round();
      if (selectedPage != page) {
        setState(() {
          selectedPage = page;
          playingAya.sura = Configs.instance.pageItems[selectedPage][0].sura;
          setLast(0);
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
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 6.0, // changes position of shadow
                                ),
                              ],
                            ),
                            height: _toolbarHeight,
                            child: Text(headerTextProvider(),
                                style: !Localization.isRTL &&
                                        Prefs.naviMode == "page"
                                    ? theme.textTheme.titleMedium
                                    : titlesStyle))),
                    footer()
                  ],
                ))));
  }

  String headerTextProvider() {
    if (Prefs.naviMode == "sura") {
      return "${String.fromCharCode(selectedPage + 204)}${String.fromCharCode(192)}";
    }
    if (Prefs.naviMode == "juze") {
      return "${String.fromCharCode(selectedPage + 327)}${String.fromCharCode(193)}";
    }
    return (selectedPage + 1).n();
  }

  Widget suraPageBuilder(BuildContext context, int p) {
    selectedIndex = selectedPage == p ? selectedIndex : 0;
    return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollStartNotification) {
            Utils.wakeup(context);
          } else if (scrollNotification is ScrollUpdateNotification) {
            onPageScroll(-scrollNotification.scrollDelta!);
          } else if (scrollNotification is ScrollEndNotification) {
            if (soundState == SoundState.playing) return true;
            var items =
                ayaList!.itemPositionsNotifier!.itemPositions.value.toList();
            for (var item in items) {
              if (item.itemLeadingEdge > 0.1 && item.itemTrailingEdge < 0.5) {
                setLast(scrollIndex = item.index);
                return true;
              }
            }
          }
          return true;
        },
        child: ayaList = ScrollablePositionedList.builder(
          initialAlignment: selectedIndex > 0 ? 0.12 : 0,
          initialScrollIndex: selectedIndex,
          itemScrollController: ItemScrollController(),
          itemPositionsListener: ItemPositionsListener.create(),
          padding: EdgeInsets.only(top: _toolbarHeight, bottom: 76),
          itemCount: Configs.instance.pageItems[p].length,
          itemBuilder: (BuildContext ctx, i) => ayaItemBuilder(p, i),
        ));
  }

  void setLast(int index) {
    Prefs.last = Configs.instance.pageItems[selectedPage][index].index;
  }

  void onPageScroll(double changes) {
    var h = (toolbarHeight + changes).clamp(0.0, _toolbarHeight);
    if (toolbarHeight != h) {
      toolbarHeight = h;
      setState(() {});
    }
  }

  Widget ayaItemBuilder(int position, int index) {
    var color = index % 2 == 0 ? theme.colorScheme.background : theme.cardColor;
    var part = Configs.instance.pageItems[position][index];
    return GestureDetector(
        onTap: () {
          Utils.wakeup(context);
          headerAnimation!.value = toolbarHeight / _toolbarHeight;
          headerAnimation!.animateTo(toolbarHeight > 0.0 ? 0.0 : 1.0,
              curve: Curves.easeOutExpo);
        },
        onLongPress: () => showAyaDetails(part.sura, part.aya),
        child: Stack(children: [
          Container(
              color: index == selectedIndex ? theme.focusColor : color,
              child: Padding(
                  padding: const EdgeInsets.only(
                      top: 14, right: 16, bottom: 5, left: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: textsProvider(part.sura, part.aya)))),
          Prefs.getNote(part.sura, part.aya) == null
              ? const SizedBox()
              : Positioned(
                  top: -18,
                  child: IconButton(
                    icon: Icon(
                      Icons.bookmark_sharp,
                      size: 14,
                      color: theme.textTheme.bodySmall!.color,
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
                    size: 16, color: theme.textTheme.bodySmall!.color),
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
        if (type == "note") {
          setState(() {});
        } else if (type == "play") {
          play(data);
        }
      }),
    ).then((value) {
      setState(() {});
    });
  }

  List<Widget> textsProvider(int sura, int aya) {
    var rows = <Widget>[];
    if (aya == 0) {
      if (Prefs.naviMode != "sura") {
        rows.add(Text(
          "${String.fromCharCode(sura + 204)}${String.fromCharCode(192)}",
          style: titlesStyle,
          textAlign: TextAlign.center,
        ));
      }
      if (sura != 0 && sura != 8) {
        rows.add(Text(
          "\n\n${String.fromCharCode(194)}",
          style: titlesStyle,
          textAlign: TextAlign.center,
        ));
      }
      rows.add(const SizedBox(height: 40));
    }

    rows.add(const SizedBox(height: 16));
    var i = 0;
    for (var p in _qurans) {
      var t = p.data![sura][aya];
      var hizbFlag = Texts.getHizbFlag(sura + 1, aya + 1, i);
      if (p.path == "ar.uthmanimin") {
        rows.add(Texts.quran(
            hizbFlag, t, "    ﴿${(aya + 1).toArabic()}﴾", uthmaniStyle));
      } else {
        rows.add(p.path == "en.transliteration"
            ? HtmlWidget("<p align=\"justify\">$t (${(aya + 1).n()}) </p>",
                textStyle: theme.textTheme.titleLarge)
            : Text("$t (${(aya + 1).n()}) ",
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.justify));
      }
      ++i;
    }

    for (var t in _otherTexts) {
      var dir =
          Bidi.isRtlLanguage(t.flag) ? TextDirection.rtl : TextDirection.ltr;
      var no = i < 1 ? (aya + 1).n(t.flag) : '';
      if (dir == TextDirection.rtl) no = no.split('').reversed.join();
      if (no.isNotEmpty) no += '. ';
      var text =
          "${dir == TextDirection.rtl ? '\u202E' : ''}\t\t\t\t\t\t\t $no${t.data![sura][aya]}";
      rows.add(Stack(
        textDirection: dir,
        children: [
          Text(text,
              textAlign: TextAlign.justify,
              textDirection: dir,
              style: theme.textTheme.bodySmall),
          Avatar(t.path!, 15)
        ],
      ));
      ++i;
    }
    return rows;
  }

  Widget footer() {
    // if (app.player == null) return Container();
    var coef = (_toolbarHeight - toolbarHeight);
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            height: 80,
            transform: Matrix4.identity()..translate(0.001, coef * 0.4),
            child: Stack(fit: StackFit.expand, children: [
              Positioned(
                  top: 24,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Container(
                      decoration: BoxDecoration(
                    color: theme.appBarTheme.backgroundColor,
                    shape: BoxShape.rectangle,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                  ))),
              Positioned(
                  top: 34 - coef * 0.11,
                  right: 86 - coef * 0.4,
                  child: Avatar(playingSound.path!, 20 - coef * 0.12)),
              Positioned(
                  top: 35 - coef * 0.2,
                  right: 132 - coef * 0.65,
                  left: 80,
                  child: Text(
                      "${playingSound.title} - ${'sura_l'.l()} ${Configs.instance.metadata.suras[playingAya.sura].title} (${(playingAya.aya + 1).n()})",
                      style: theme.textTheme.labelLarge,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right)),
              Positioned(
                  top: 24,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: GestureDetector(
                      onTap: () =>
                          goto(playingAya.sura, playingAya.aya, force: true))),
              Positioned(
                  top: 24,
                  bottom: 0,
                  child: Opacity(
                      opacity: toolbarHeight / _toolbarHeight,
                      child: getButton("texts"))),
              Positioned(
                  top: 24,
                  bottom: 0,
                  left: 44,
                  child: Opacity(
                      opacity: toolbarHeight / _toolbarHeight,
                      child: getButton("sounds"))),
              Positioned(
                  top: coef * 0.15,
                  right: _toolbarHeight * 0.5 - coef * 0.15,
                  child: SizedBox(
                      height: _toolbarHeight * 0.7 + toolbarHeight * 0.3,
                      width: _toolbarHeight * 0.7 + toolbarHeight * 0.3,
                      child: getToggleButton(context)))
            ])));
  }

  Future<void> footerPressed(PType type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonPage(type)),
    );
    updatePlayer();
    setState(() {});
  }

  void goto(int sura, int aya, {bool force = false}) {
    var part = Configs.instance.getPart(sura, aya);
    var page = part[0];
    var index = part[1];
    if (page == selectedPage && index == selectedPage) return;
    Prefs.last = Configs.instance.pageItems[page][index].index;
    // print("sura $sura aya $aya page $page index $index");

    if (page != selectedPage) {
      if (!force && index != 0) return;
      var dis = (page - selectedPage).abs();
      gotoPage(page, dis > 3 ? 0 : 400);
      Future.delayed(
          const Duration(milliseconds: 500), () => gotoIndex(index, 800));
    } else {
      gotoIndex(index, 800);
    }
  }

  void gotoPage(int page, int duration) {
    if (duration == 0) {
      suraPageController!.jumpToPage(page);
    } else {
      suraPageController!.animateToPage(page,
          duration: Duration(milliseconds: duration), curve: Curves.easeInOut);
    }
  }

  void gotoIndex(int index, int duration) {
    debugPrint("index $index, duration $duration");
    selectedIndex = index;
    setState(() {});
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
        stream: widget.audioHandler.playbackState
            .map((state) => state.playing)
            .distinct(),
        builder: (context, snapshot) {
          if (soundState.index > SoundState.ready.index) {
            soundState = (snapshot.data ?? false)
                ? SoundState.playing
                : SoundState.pause;
          }
          return FloatingActionButton(
              heroTag: "fab",
              onPressed: onTogglePressed,
              child: Icon(getIcon()));
        });
  }

  IconData getIcon() {
    switch (soundState) {
      case SoundState.loading:
        return Icons.hourglass_bottom;
      case SoundState.playing:
        return Icons.pause;
      default:
        return Icons.play_arrow;
    }
  }

  IconButton getButton(String type) {
    switch (type) {
      case "settings":
        return IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => showModalBottomSheet(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: theme.dialogBackgroundColor,
            context: context,
            isScrollControlled: true,
            builder: (context) => SettingsPopup(() => setState(() {})),
          ),
        );
      case "search":
        return IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchPage(widget.audioHandler)),
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
    // print("initAudio c ${AudioService.connected} r ${AudioService.running}");
    // if (AudioService.connected && widget.audioHandler.playbackState. == pros) return;

    soundState = SoundState.loading;
    setState(() {});
    List<String>? sounds = Prefs.persons[PType.sound];
    playingSound = Configs.instance.sounds[sounds![0]]!;
    // await AudioService.start(
    //     backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
    //     androidNotificationChannelName: 'قرآن هدایت',
    //     // Enable this if you want the Android service to exit the foreground state on pause.
    //     //androidStopForegroundOnPause: true,
    //     androidNotificationColor: Colors.amber.value,
    //     androidNotificationIcon: 'mipmap/ic_launcher',
    //     androidEnableQueue: true,
    //     params: {"ayas": jsonEncode(Configs.instance.navigations["all"]![0])});
    updatePlayer();
    soundState = SoundState.ready;
    setState(() {});

    widget.audioHandler.customEvent.listen((state) {
      if (_disposed) return;
      var event = json.decode(state as String);
      if (event["type"] == "select") {
        playingAya = Configs.instance.navigations["all"]![0][event["data"][0]];
        playingSound = Configs.instance.sounds[sounds[event["data"][1]]]!;
        soundState = SoundState.playing;
        goto(playingAya.sura, playingAya.aya);
      } else if (event["type"] == "stop") {
        soundState = SoundState.stop;
        setState(() {});
      }
    });
  }

  void onTogglePressed() async {
    // await initAudio();
    if (soundState == SoundState.pause || soundState == SoundState.playing) {
      soundState == SoundState.playing
          ? widget.audioHandler.pause()
          : widget.audioHandler.play();
      return;
    }
    play(Configs.instance.pageItems[selectedPage][scrollIndex].index);
  }

  void play(int index) async {
    soundState = SoundState.loading;
    setState(() {});
    // await initAudio();
    widget.audioHandler.customAction("select", {"index": index});
  }

  void updatePlayer() {
    var suras = <String>[];
    for (var s in Configs.instance.metadata.suras) {
      suras.add(s.title);
    }
    var sounds = <Person>[];
    for (var p in Prefs.persons[PType.sound]!) {
      sounds.add(Configs.instance.sounds[p]!);
    }
    widget.audioHandler
        .customAction("update", {"sounds": jsonEncode(sounds), "suras": suras});
  }

  @override
  void dispose() {
    _disposed = true;
    Wakelock.disable();
    super.dispose();
  }
}

enum SoundState { stop, loading, ready, playing, pause }
