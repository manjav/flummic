import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:islamic/models.dart';
import 'package:islamic/pages/home.dart';
import 'package:islamic/widgets/popup.dart';

import '../utils/localization.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({Key key}) : super(key: key);
  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  TabController _tabController;

  Icon searchIcon = Icon(Icons.search);
  TextEditingController searchController = TextEditingController();

  ThemeData theme;
  TextStyle suraStyle;
  TextStyle uthmaniStyle;

  bool reversed = false;
  String lastSort = "suras";
  List<Sura> suras;
  List<String> notes;
  double toolbarHeight = 0;
  final _toolbarHeight = 56.0;
  double startScrollBarIndicator = 0;
  ScrollController suraListController;

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

    suraStyle = TextStyle(
        fontFamily: 'SuraNames',
        fontSize: 28,
        height: Localization.isRTL ? 1.1 : 0.1);
    uthmaniStyle = Localization.isRTL
        ? TextStyle(fontFamily: 'Uthmani', fontSize: 20)
        : TextStyle(
            fontFamily: 'CubicSans-regular',
            fontSize: 15,
            fontWeight: FontWeight.bold);

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
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
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
    );
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
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
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
            height: Localization.isRTL ? 56 : 72,
            color: index % 2 == 0 ? theme.backgroundColor : theme.cardColor,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                child: Row(
                  children: [
                    Stack(children: [
                      SvgPicture.asset(
                        "images/${sura.type == 0 ? 'meccan' : 'median'}.svg",
                        color: theme.primaryColor,
                        width: 48,
                        height: 48,
                      ),
                      Positioned(
                          top: 14,
                          bottom: 14,
                          right: 4,
                          left: 4,
                          child: Text("${sura.index + 1}",
                              style: uthmaniStyle, textAlign: TextAlign.center))
                    ]),
                    SizedBox(width: 8, height: 48),
                    Expanded(
                        child: Container(
                            padding: EdgeInsets.only(
                                top: Localization.isRTL ? 5 : 28),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                        "${String.fromCharCode(sura.index + 13)}",
                        style: suraStyle,
                      ),
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
        width: 64,
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
            width: 64,
            height: _toolbarHeight,
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
                            ? theme.textTheme.bodyText1.color
                            : theme.textTheme.subtitle2.color),
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
    return GestureDetector(
        onTap: () => goto(juz.sura - 1, juz.aya - 1),
        child: Container(
            height: 72,
            color: index % 2 == 0 ? theme.backgroundColor : theme.cardColor,
            child: Padding(
                padding: EdgeInsets.only(
                    left: Localization.isRTL ? 4 : 16,
                    right: Localization.isRTL ? 16 : 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        "juze_l".l() + " " + "j_${index + 1}".l(),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                    getHizb(index * 8),
                    getHizb(index * 8 + 1),
                    getHizb(index * 8 + 2),
                    getHizb(index * 8 + 3)
                  ],
                ))));
  }

  Widget getHizb(int index) {
    var hizb = Configs.instance.metadata.hizbs[index];
    return IconButton(
      iconSize: 40,
      icon: SvgPicture.asset(
        "images/quarter_${index % 8}.svg",
        width: 40,
        height: 40,
      ),
      onPressed: () => goto(hizb.sura - 1, hizb.aya - 1),
    );
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
                  )),
                  IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 20,
                      ),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              Generics.editNote(context, theme, sura, aya)))
                ]))));
  }

  void goto(int sura, int aya) {
    Prefs.selectedSura = sura;
    Prefs.selectedAya = aya;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }
}
