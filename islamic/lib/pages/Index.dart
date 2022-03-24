import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:islamic/models.dart';
import 'package:islamic/pages/home.dart';
import 'package:islamic/pages/web.dart';
import 'package:islamic/widgets/popup.dart';
import 'package:islamic/widgets/rating.dart';

import '../main.dart';
import '../utils/localization.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key? key}) : super(key: key);
  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  TabController? _tabController;

  Icon searchIcon = Icon(Icons.search);
  TextEditingController searchController = TextEditingController();

  TextStyle? titlesStyle;
  TextStyle? uthmaniStyle;

  List<Sura> suras = <Sura>[];
  List<Note> notes = <Note>[];
  bool reversed = false;
  String lastSort = "suras";
  double toolbarHeight = 0;
  int selectedJuzIndex = -1;
  final _toolbarHeight = 56.0;
  double startScrollBarIndicator = 0;
  ScrollController? suraListController;

  AnimationController? hizbAnimation;
  AnimationController? removeAnimation;

  @override
  void initState() {
    super.initState();
    hizbAnimation = AnimationController(vsync: this);
    hizbAnimation!.addListener(() => setState(() {}));

    removeAnimation = AnimationController(vsync: this);
    removeAnimation!.addListener(() => setState(() {}));

    _tabController = TabController(length: 3, vsync: this);
    toolbarHeight = _toolbarHeight;
    suraListController = ScrollController();
    suraListController!.addListener(() {
      var changes =
          startScrollBarIndicator - suraListController!.position.pixels;
      startScrollBarIndicator = suraListController!.position.pixels;
      var h = (toolbarHeight + changes).clamp(0.0, _toolbarHeight);
      if (toolbarHeight != h) {
        toolbarHeight = h;
        setState(() {});
      }
    });
    suras = Configs.instance.metadata.suras;
    Future.delayed(Duration(seconds: 1)).then((_) {
      showRating();
      // showSurveys();
    }); //this inside the initstate

    createNotes();
  }

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    var theme = Theme.of(context);
    titlesStyle = TextStyle(
        fontFamily: 'titles',
        fontSize: queryData.devicePixelRatio > 1.5 ? 24 : 20,
        letterSpacing: -2,
        height: Localization.isRTL ? 1.1 : 0.1);
    uthmaniStyle = Localization.isRTL
        ? TextStyle(fontFamily: 'mequran', fontSize: 20)
        : TextStyle(
            fontFamily: 'cubicsans-regular',
            fontSize: 15,
            fontWeight: FontWeight.bold);
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: _toolbarHeight - 8,
          // toolbarOpacity: toolbarHeight / _toolbarHeight,
          // title: const Text('TabBar Widget'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: "suras_l".l()),
              Tab(text: "juzes_l".l()),
              Tab(text: "notes_l".l())
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [getSuras(theme), getJuzes(theme), getNotes(theme)],
        ),
        bottomNavigationBar: footer(theme));
  }

  Widget footer(ThemeData theme) {
    var last = Configs.instance.navigations["all"]![0][Prefs.last];
    var sura = Configs.instance.metadata.suras[last.sura];
    return Prefs.last == 0
        ? SizedBox(height: 0)
        : Container(
            height: HomePageState.soundState == SoundState.playing ? 100 : 64,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                      onTap: () => goto(last.sura, last.aya),
                      child: Container(
                          height: 64,
                          color: theme.buttonColor,
                          child: Padding(
                              padding: EdgeInsets.only(
                                  right: Localization.isRTL ? 16 : 0,
                                  left: Localization.isRTL ? 0 : 16),
                              child: Row(children: [
                                Icon(Icons.arrow_back),
                                SizedBox(width: 16),
                                Text(
                                  "${'last_l'.l()} :  ${'sura_l'.l()} ${sura.title}  ( ${(last.aya + 1).n()} )",
                                  style: theme.textTheme.caption,
                                ),
                              ])))),
                  HomePageState.soundState != SoundState.playing
                      ? SizedBox()
                      : Container(
                          height: 36,
                          color: theme.appBarTheme.backgroundColor,
                          child: Row(
                            children: [
                              SizedBox(width: 16),
                              Expanded(
                                  child: Text("playing_l".l(),
                                      textDirection: Localization.dir,
                                      style: theme.textTheme.bodyText2)),
                              IconButton(
                                  icon: Icon(Icons.stop, size: 16),
                                  onPressed: () {
                                    AudioService.stop();
                                    HomePageState.soundState = SoundState.stop;
                                    setState(() {});
                                  })
                            ],
                          ))
                ]));
  }

  Widget getSuras(ThemeData theme) {
    return Stack(children: [
      ListView.builder(
          padding: EdgeInsets.only(top: _toolbarHeight),
          itemBuilder: (BuildContext c, int i) => suraItemBuilder(theme, i),
          controller: suraListController,
          itemCount: suras.length),
      Container(
          height: _toolbarHeight,
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
          child: Padding(
              padding: EdgeInsets.only(
                  top: 5,
                  right: Localization.isRTL ? 8 : 0,
                  left: Localization.isRTL ? 0 : 8),
              child: Row(
                children: [
                  Expanded(
                    child: getHeader(theme, "suras"),
                  ),
                  getHeader(theme, "order"),
                  getHeader(theme, "ayas"),
                  getHeader(theme, "page")
                ],
              )))
    ]);
  }

  Widget suraItemBuilder(ThemeData theme, int index) {
    var sura = suras[index];
    return GestureDetector(
        onTap: () => goto(sura.index!, 0),
        child: Container(
            height: Localization.isRTL ? 64 : 72,
            color: index % 2 == 0 ? theme.backgroundColor : theme.cardColor,
            child: Padding(
                padding: EdgeInsets.only(
                    right: Localization.isRTL ? 8 : 0,
                    left: Localization.isRTL ? 0 : 8),
                child: Row(
                  children: [
                    Stack(children: [
                      SvgPicture.asset(
                        "images/${sura.type == 0 ? 'meccan' : 'median'}.svg",
                        color: theme.primaryColor,
                        width: 36,
                        height: 36,
                      ),
                      Positioned(
                          top: 11,
                          bottom: 6,
                          right: 2,
                          left: 2,
                          child: Text("${sura.index! + 1}",
                              style: uthmaniStyle, textAlign: TextAlign.center))
                    ]),
                    SizedBox(width: 4, height: 48),
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.only(
                                top: Localization.isRTL ? 0 : 28),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${String.fromCharCode(sura.index! + 204)}${String.fromCharCode(192)}",
                                      style: titlesStyle,
                                      textDirection: TextDirection.ltr),
                                  Localization.isRTL
                                      ? SizedBox(height: 0)
                                      : SizedBox(height: 4),
                                  Localization.isRTL
                                      ? SizedBox(height: 0)
                                      : Text("    ${sura.title}",
                                          style: TextStyle(fontSize: 12))
                                ]))),
                    getText(sura.order!),
                    getText(sura.ayas!),
                    getText(sura.page!)
                  ],
                ))));
  }

  Container getText(int value) {
    return Container(
        width: 50,
        height: 16,
        alignment: Alignment.center,
        child: Text("$value", style: uthmaniStyle));
  }

  GestureDetector getHeader(ThemeData theme, String value) {
    return GestureDetector(
        onTap: () {
          if (lastSort == value) {
            reversed = !reversed;
            suras = suras.reversed.toList();
          } else {
            reversed = false;
            lastSort = value;
            suras.sort((Sura l, Sura r) {
              if (value == "ayas")
                return l.ayas!.compareTo(r.ayas!);
              else if (value == "order") return l.order!.compareTo(r.order!);
              return l.index!.compareTo(r.index!);
            });
          }
          setState(() {});
        },
        child: Container(
            width: 50,
            height: _toolbarHeight,
            color: Colors.transparent,
            child: Stack(alignment: Alignment.topCenter,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${value}_l".l(),
                    style: lastSort == value
                        ? theme.textTheme.bodyText1
                        : theme.textTheme.subtitle2,
                  ),
                  Positioned(
                    child: Icon(
                        reversed && lastSort == value
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: lastSort == value
                            ? theme.textTheme.bodyText1!.color
                            : theme.textTheme.subtitle2!.color),
                    top: 24,
                  )
                ])));
  }

  // ____________________________________________________________
  Widget getJuzes(ThemeData theme) {
    return ListView.builder(
        itemBuilder: (BuildContext c, int i) => juzeItemBuilder(theme, i),
        itemCount: Configs.instance.metadata.juzes.length);
  }

  Widget juzeItemBuilder(ThemeData theme, int index) {
    var juz = Configs.instance.metadata.juzes[index];
    var j = index + 1;
    return GestureDetector(
        onTap: () {
          selectedJuzIndex = index;
          hizbAnimation!.value = 0;
          hizbAnimation!.animateTo(1, duration: Duration(milliseconds: 1000));
        },
        child: Container(
            height: 80,
            color: index % 2 == 0 ? theme.backgroundColor : theme.cardColor,
            child: Padding(
                padding: EdgeInsets.only(
                    top: 6,
                    left: Localization.isRTL ? 4 : 12,
                    right: Localization.isRTL ? 12 : 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            Localization.isRTL
                                ? "$j. ${String.fromCharCode(index + 327)}${String.fromCharCode(193)}"
                                : "$j. " + "n_$j".l() + " " + "juze_l".l(),
                            style: Localization.isRTL
                                ? titlesStyle
                                : theme.textTheme.subtitle1),
                        Text(
                            "${'sura_l'.l()} ${Configs.instance.metadata.suras[juz.sura - 1].title} ${'aya_l'.l()} ${juz.aya.n()}",
                            style: theme.textTheme.caption)
                      ],
                    )),
                    getHizb(theme, index, 0),
                    getHizb(theme, index, 1),
                    getHizb(theme, index, 2),
                    getHizb(theme, index, 3)
                  ],
                ))));
  }

  Widget getHizb(ThemeData theme, int juzIndex, int hizbIndex) {
    var hidden = juzIndex != selectedJuzIndex;
    if (hidden) return SizedBox();
    var hIndex = juzIndex * 8 + hizbIndex * 2;
    var hizb = Configs.instance.metadata.hizbs[hIndex];
    return Opacity(
        opacity: (hizbAnimation!.value - (hizbIndex * 0.05)).clamp(0.0, 1.0),
        child: GestureDetector(
            onTap: () => goto(hizb.sura - 1, hizb.aya - 1),
            child: Container(
                width: 48,
                padding: EdgeInsets.only(top: 6),
                child: Column(children: [
                  SvgPicture.asset(
                    "images/quarter_$hizbIndex.svg",
                    height: 36,
                  ),
                  Text("hizb_l".l() + " " + (hizbIndex + 1).n(),
                      style: theme.textTheme.caption)
                ]))));
  }

  // ____________________________________________________________

  void createNotes() {
    notes.clear();
    for (var k in Prefs.notes.keys)
      notes.add(Note(int.parse(k.substring(0, 3)), int.parse(k.substring(3)),
          Prefs.notes[k]!));
  }

  Widget getNotes(ThemeData theme) {
    return notes.length == 0
        ? Center(
            child: Text("note_empty".l(),
                style: theme.textTheme.caption, textAlign: TextAlign.center))
        : ListView.builder(
            itemBuilder: (c, int i) => noteItemBuilder(c, theme, i),
            itemCount: notes.length);
  }

  Widget noteItemBuilder(BuildContext context, ThemeData theme, int index) {
    var note = notes[index];
    return GestureDetector(
        onTap: () => goto(note.sura, note.aya),
        child: Stack(children: [
          Container(
              height: 72,
              color: index % 2 == 0 ? theme.backgroundColor : theme.cardColor,
              child: Padding(
                  padding: EdgeInsets.only(
                      left: Localization.isRTL ? 4 : 16,
                      right: Localization.isRTL ? 16 : 4),
                  child: Row(children: [
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${'sura_l'.l()} ${Configs.instance.metadata.suras[note.sura].title} - ${'aya_l'.l()} ${(note.aya + 1).n()}",
                          style: theme.textTheme.subtitle1,
                        ),
                        note.text.length > 0
                            ? Text(note.text, overflow: TextOverflow.ellipsis)
                            : SizedBox()
                      ],
                    )),
                    IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 20,
                        ),
                        onPressed: () => showDialog(
                            context: context,
                            builder: (BuildContext context) =>
                                Generics.editNote(
                                    context,
                                    theme,
                                    note.sura,
                                    note.aya,
                                    (string, number) => setState(() {})))),
                    SizedBox(width: 64)
                  ]))),
          note.removing
              ? Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    color: theme.backgroundColor.withOpacity(0.8),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("undo_b".l(), style: theme.textTheme.subtitle1),
                          SizedBox(height: 16),
                          LinearProgressIndicator(value: removeAnimation!.value)
                        ]),
                  ))
              : SizedBox(),
          Positioned(
              top: 8,
              bottom: 8,
              left: Localization.isRTL ? 8 : null,
              right: Localization.isRTL ? null : 8,
              child: IconButton(
                  icon: Icon(
                    note.removing ? Icons.restore_from_trash : Icons.delete,
                  ),
                  onPressed: () => _removeNote(note)))
        ]));
  }

  void _removeNote(Note note) {
    if (note.removing) {
      note.cancelRemove();
      setState(() {});
      return;
    }

    const duration = Duration(seconds: 3);
    note.remove(
        duration,
        () => setState(() {
              createNotes();
            }));
    removeAnimation!.value = 0;
    removeAnimation!
        .animateTo(1, duration: duration, curve: Curves.easeOutSine);
  }

  void goto(int sura, int aya) async {
    Prefs.selectedSura = sura;
    Prefs.selectedAya = aya;
    var part = Configs.instance.getPart(sura, aya);
    HomePageState.selectedPage = part[0];
    HomePageState.selectedIndex = part[1];
    Prefs.instance.setInt("last", part[2]);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AudioServiceWidget(child: HomePage())));
    createNotes();
  }

  /* void showSurveys() async {
    for (var s in Configs.instance.configs["surveys"]) {
      if (s["url"] != "" &&
          s["availableAt"] < Prefs.numRuns &&
          s["languageCode"] == Localization.languageCode &&
          Prefs.surveys.indexOf(s["id"]) < 0) {
        print("Survey ${s["id"]} in ${s["availableAt"]}/${Prefs.numRuns}");
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => WebPage(data: s)));
        Prefs.addSurvey(s["id"]);
        return;
      }
    }
  } */

  void showRating() async {
    print("showRating Prefs.rate: ${Prefs.rate}, num runs: ${Prefs.numRuns}");
    // Send to store
    if (Prefs.rate == 5) {
      if (Configs.instance.buildConfig!.target == "cafebazaar") {
        if (Platform.isAndroid) {
          AndroidIntent intent = AndroidIntent(
              data: 'bazaar://details?id=com.gerantech.muslim.holy.quran',
              action: 'android.intent.action.EDIT',
              package: 'com.farsitel.bazaar');
          await intent.launch();
        }
        Prefs.instance.setInt("rate", 1000000);
        return;
      }

      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        if (!Prefs.instance.containsKey("rated")) {
          inAppReview.requestReview();
          Prefs.instance.setBool("rated", true);
          return;
        }
        inAppReview.openStoreListing();
        Prefs.instance.setInt("rate", 1000000);
      }
      return;
    }

    // Repeat rating request
    if (Prefs.numRuns <= Prefs.rate) return;
    int rating = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) =>
            WillPopScope(onWillPop: () async => false, child: RatingDialog()));

    Prefs.instance.setInt("rate", rating >= 5 ? rating : (Prefs.rate + 10));

    String comment = "";
    if (rating > 0) {
      if (rating < 5) {
        comment = await showDialog(
            context: context,
            builder: (context) => WillPopScope(
                onWillPop: () async => false, child: ReviewDialog()));
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("thanks_l".l()),
      ));
    }
    AppState.analytics.logEvent(
      name: 'rate',
      parameters: <String, dynamic>{
        'numRuns': Prefs.numRuns,
        'rating': rating,
        'comment': comment
      },
    );
    print(" Prefs.rate: ${Prefs.rate} rating: $rating comment: $comment");
  }
}
