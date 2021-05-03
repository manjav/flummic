import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:islamic/models.dart';
import 'package:islamic/pages/home.dart';
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
  late TabController _tabController;

  Icon searchIcon = Icon(Icons.search);
  TextEditingController searchController = TextEditingController();

  late ThemeData theme;
  late TextStyle titlesStyle;
  late TextStyle uthmaniStyle;

  bool reversed = false;
  String lastSort = "suras";
  late List<Sura> suras;
  late List<String> notes;
  double toolbarHeight = 0;
  int selectedJuzIndex = -1;
  final _toolbarHeight = 56.0;
  double startScrollBarIndicator = 0;
  late ScrollController suraListController;

  late Tween<double> tween;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      value: 0,
      vsync: this,
    );
    controller.addListener(() {
      setState(() {});
    });
    tween = Tween<double>(begin: 0.0, end: 2.800);

    _tabController = TabController(length: 3, vsync: this);
    toolbarHeight = _toolbarHeight;
    suraListController = ScrollController();
    suraListController.addListener(() {
      var changes =
          startScrollBarIndicator - suraListController.position.pixels;
      startScrollBarIndicator = suraListController.position.pixels;
      var h = (toolbarHeight + changes).clamp(0.0, _toolbarHeight);
      if (toolbarHeight != h) {
        toolbarHeight = h;
        setState(() {});
      }
    });
    suras = Configs.instance.metadata.suras;
    Future.delayed(Duration(seconds: 1))
        .then((_) => showRating()); //this inside the initstate
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    titlesStyle = TextStyle(
        fontFamily: 'titles',
        fontSize: 24,
        letterSpacing: -4,
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
          children: [getSuras(), getJuzes(), getNotes()],
        ),
        bottomNavigationBar: getAudioLine());
  }

  Widget getAudioLine() {
    if (HomePageState.soundState != 1) return SizedBox();
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
            color: theme.appBarTheme.backgroundColor,
            height: 36,
            child: Row(
              children: [
                SizedBox(width: 4),
                // Avatar(quran!.playingSound!.path, 12),
                // SizedBox(width: 4),
                Expanded(
                    child: Text("playing_l".l(),
                        style: theme.textTheme.bodyText2)),
                IconButton(
                    icon: Icon(Icons.stop, size: 16),
                    onPressed: () {
                      AudioService.stop();
                      HomePageState.soundState = 0;
                      setState(() {});
                    })
              ],
            )));
  }

  Widget getSuras() {
    return Stack(children: [
      ListView.builder(
          padding: EdgeInsets.only(top: _toolbarHeight),
          itemBuilder: suraItemBuilder,
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
                    child: getHeader("suras"),
                  ),
                  getHeader("order"),
                  getHeader("ayas"),
                  getHeader("page")
                ],
              )))
    ]);
  }

  Widget suraItemBuilder(context, int index) {
    var sura = suras[index];
    return GestureDetector(
        onTap: () => goto(sura.index, 0),
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
                          top: 8,
                          bottom: 8,
                          right: 4,
                          left: 4,
                          child: Text("${sura.index + 1}",
                              style: uthmaniStyle, textAlign: TextAlign.center))
                    ]),
                    SizedBox(width: 8, height: 48),
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.only(
                                top: Localization.isRTL ? 0 : 28),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${String.fromCharCode(sura.index + 204)}${String.fromCharCode(192)}",
                                      style: titlesStyle,
                                      textDirection: TextDirection.ltr),
                                  Localization.isRTL
                                      ? SizedBox(height: 0)
                                      : SizedBox(height: 4),
                                  Localization.isRTL
                                      ? SizedBox(height: 0)
                                      : Text("    ${sura.title}")
                                ]))),
                    getText(sura.order),
                    getText(sura.ayas),
                    getText(sura.page)
                  ],
                ))));
  }

  Container getText(int value) {
    return Container(
        width: 56,
        height: 16,
        alignment: Alignment.center,
        child: Text("$value", style: uthmaniStyle));
  }

  GestureDetector getHeader(String value) {
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
                return l.ayas.compareTo(r.ayas);
              else if (value == "order")
                return l.order.compareTo(r.order);
              else
                return l.index.compareTo(r.index);
            });
          }
          setState(() {});
        },
        child: Container(
            width: 56,
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
  Widget getJuzes() {
    return ListView.builder(
        itemBuilder: juzeItemBuilder,
        itemCount: Configs.instance.metadata.juzes.length);
  }

  Widget juzeItemBuilder(context, int index) {
    var juz = Configs.instance.metadata.juzes[index];
    var j = index + 1;
    return GestureDetector(
        onTap: () {
          selectedJuzIndex = index;
          controller.value = 0;
          controller.animateTo(1);
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
                                : "$j. " + "j_$j".l() + " " + "juze_l".l(),
                            style: Localization.isRTL
                                ? titlesStyle
                                : theme.textTheme.subtitle1),
                        Text(
                            "${'sura_l'.l()} ${Configs.instance.metadata.suras[juz.sura - 1].title} ${'verse_l'.l()} ${juz.aya.n()}",
                            style: theme.textTheme.caption)
                      ],
                    )),
                    getHizb(index, 0),
                    getHizb(index, 1),
                    getHizb(index, 2),
                    getHizb(index, 3)
                  ],
                ))));
  }

  Widget getHizb(int juzIndex, int hizbIndex) {
    var hidden = juzIndex != selectedJuzIndex;
    if (hidden) return SizedBox();
    var hIndex = juzIndex * 8 + hizbIndex * 2;
    var hizb = Configs.instance.metadata.hizbs[hIndex];
    return Opacity(
        opacity: (controller.value - (hizbIndex * 0.05)).clamp(0.0, 1.0),
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

  Widget getNotes() {
    notes = Prefs.notes.keys.toList();
    return notes.length == 0
        ? Center(
            child: Text("note_empty".l(),
                style: theme.textTheme.caption, textAlign: TextAlign.center))
        : ListView.builder(
            itemBuilder: noteItemBuilder, itemCount: notes.length);
  }

  Widget noteItemBuilder(BuildContext context, int index) {
    var sura = int.parse(notes[index].substring(0, 3));
    var aya = int.parse(notes[index].substring(3));
    String? text = Prefs.getNote(sura, aya);
    return GestureDetector(
        onTap: () => goto(sura, aya),
        child: Container(
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
                        "${'sura_l'.l()} ${Configs.instance.metadata.suras[sura].title} - ${'verse_l'.l()} ${(aya + 1).n()}",
                        style: theme.textTheme.subtitle1,
                      ),
                      text!.length > 0
                          ? Text(text, overflow: TextOverflow.ellipsis)
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
                          builder: (BuildContext context) => Generics.editNote(
                              context,
                              theme,
                              sura,
                              aya,
                              () => setState(() {})))),
                  IconButton(
                      icon: Icon(
                        Icons.delete,
                        size: 20,
                      ),
                      onPressed: () {
                        Prefs.removeNote(sura, aya);
                        setState(() {});
                      })
                ]))));
  }

  void goto(int sura, int aya) async {
    Prefs.selectedSura = sura;
    Prefs.selectedAya = aya;
    var res = Configs.instance.getPart(sura, aya);
    HomePageState.selectedPage = res[0];
    HomePageState.selectedIndex = res[1];
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AudioServiceWidget(child: HomePage())));
    setState(() {});
  }

  void showRating() async {
    print("showRating Prefs.rate: ${Prefs.rate}, num runs: ${Prefs.numRuns}");
    // Send to store
    if (Prefs.rate == 5) {
      Prefs.instance.setInt("rate", 500);
      var data = await rootBundle.loadString('texts/buildconfigs.json');
      var configs = jsonDecode(data);
      if (configs["target"] == "cafebazaar") {
        if (Platform.isAndroid) {
          AndroidIntent intent = AndroidIntent(
              data: 'bazaar://details?id=com.gerantech.muslim.holy.quran',
              action: 'android.intent.action.EDIT',
              package: 'com.farsitel.bazaar');
          await intent.launch();
        }
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
      AppState.analytics.logEvent(
        name: 'rate',
        parameters: <String, dynamic>{
          'numRuns': Prefs.numRuns,
          'rating': rating,
          'comment': comment
        },
      );
    }
    print(" Prefs.rate: ${Prefs.rate} rating: $rating comment: $comment");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("thanks_l".l()),
    ));
  }
}
