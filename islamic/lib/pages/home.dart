import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:islamic/widgets/player.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models.dart';
import '../pages/persons.dart';
import '../utils/localization.dart';
import '../buttons.dart';
import '../main.dart';

class HomePage extends StatefulWidget {
  final selectedSura;
  final selectedAya;
  HomePage(this.selectedSura, this.selectedAya);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _toolbarHeight = 56.0;
  PageController suraPageController;
  ItemScrollController itemScrollController;
  ItemPositionsListener itemPositionsListener;
  TextStyle suraStyle = TextStyle(fontFamily: 'SuraNames', fontSize: 32);
  TextStyle uthmaniStyle;
  TextStyle uthmaniStyleLight;
  int selectedSura = 0;
  int selectedAya = 0;
  double toolbarHeight;
  double startScrollBarIndicator = 0;
  bool hasQuranText = false;
  ThemeData theme;
  AppState app;

  void initState() {
    selectedSura = widget.selectedSura;
    selectedAya = widget.selectedAya;
    super.initState();
    hasQuranText = Prefs.persons[PType.text].indexOf("ar.uthmanimin") > -1;
    toolbarHeight = _toolbarHeight;
    suraPageController =
        PageController(keepPage: true, initialPage: widget.selectedSura);
    suraPageController.addListener(() {
      var page = suraPageController.page.round();
      if (page != selectedSura) {
        setState(() {
          toolbarHeight = _toolbarHeight;
          selectedSura = page;
        });
      }
    });

    app = MyApp.of(context);
    if (app.player == null) app.player = Player();
    app.player.onStateChange = playerOnStateChange;
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    uthmaniStyle = TextStyle(
        fontFamily: 'Uthmani', fontSize: 20, height: 2, wordSpacing: 2);
    uthmaniStyleLight = TextStyle(
        fontFamily: 'Uthmani',
        fontSize: 22,
        height: 2,
        letterSpacing: 2,
        color: theme.backgroundColor);

    return new Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
            appBar: AppBar(
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
                leading: Row(children: [
                  IconButton(
                    icon: new Icon(Icons.settings),
                    onPressed: () => app.setTheme(
                        app.themeMode == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark),
                  ),
                  IconButton(
                    icon: new Icon(Icons.search),
                    onPressed: () {
                      itemScrollController.scrollTo(
                          index: 123,
                          duration: Duration(seconds: 1),
                          curve: Curves.easeInOut);
                    },
                  )
                ]),
                // toolbarHeight: toolbarHeight,
                // toolbarOpacity: toolbarHeight / _toolbarHeight
                leadingWidth: _toolbarHeight * 2,
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
            )));
  }

  Widget suraPageBuilder(BuildContext context, int p) {
    var len = Configs.instance.metadata.suras[p].ayas;
    return ScrollablePositionedList.builder(
      
      itemScrollController: itemScrollController = ItemScrollController(),
      itemPositionsListener: itemPositionsListener =
          ItemPositionsListener.create(),
      initialScrollIndex: selectedAya,
      padding: EdgeInsets.only(top: _toolbarHeight + 10, bottom: 24),
      itemCount: len,
      itemBuilder: (BuildContext ctx, i) => ayaItemBuilder(p, i),
      onScroll: onPageScroll,
      // controller: ayaScrollController
    );
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
    // selectedAya = index;
    return Container(
        color: index % 2 == 0 ? theme.backgroundColor : theme.cardColor,
        child: GestureDetector(
            onTap: () => setState(() {
                  // var tween = Tween<double>(begin: -200, end: 0);
                  toolbarHeight = _toolbarHeight;
                  // app.player.select(selectedSura, index, 0, true);
                }),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: textsProvider(position, index)))));
  }

  List<Widget> textsProvider(int sura, int aya) {
    var rows = <Widget>[];

    // rows.add(Row(
    //   children: [
    //     CircleButton(icon: Icons.bookmark),
    //     SizedBox(width: 8),
    //     CircleButton(icon: Icons.share),
    //     Spacer(),
    //     CircleButton(text: (aya + 1).toString()),
    //   ],
    // ));
    // rows.add(SizedBox(height: 20));
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
    if (hasQuranText)
      rows.add(Text(
          "${Configs.instance.quran[sura][aya]} ﴿${(aya + 1).toArabic()}﴾",
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          style: uthmaniStyle));

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
      )

          //   ListTile(
          //   leading: isRTL ? null : icon,
          //   trailing: isRTL ? icon : null,
          //   title: ,
          // )
          );
      // rows.add(SizedBox(height: 6));
    }
    // rows.add(Divider(color: Colors.black45));
    return rows;
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
                        child: IconButton(
                            icon: Icon(Icons.add_comment_outlined,
                                color: theme.appBarTheme.iconTheme.color),
                            onPressed: () => footerPressed(PType.text)))),
                Positioned(
                    top: 0,
                    bottom: 0,
                    left: 48,
                    child: Opacity(
                        opacity: toolbarHeight / _toolbarHeight,
                        child: IconButton(
                            icon: Icon(Icons.headset_sharp,
                                color: theme.appBarTheme.iconTheme.color),
                            onPressed: () => footerPressed(PType.sound)))),
                Positioned(
                    top: 10 - coef * 0.11,
                    right: 86 - coef * 0.4,
                    child: Avatar(app.player.sound.path, 20 - coef * 0.12)),
                Positioned(
                    top: 10 - coef * 0.2,
                    right: 132 - coef * 0.65,
                    child: Text(
                      app.player.sound.name,
                      style: theme.textTheme.subtitle2,
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
            decoration: new BoxDecoration(
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
    setState(() =>
        hasQuranText = Prefs.persons[PType.text].indexOf("ar.uthmanimin") > -1);
  }

  Future<void> playerOnStateChange(AudioPlayerState state) async {
    setState(() {});
    if (state != AudioPlayerState.PLAYING) return;
    goto(app.player.sura, app.player.aya);
  }

  void goto(int sura, int aya) {
    if (sura != selectedSura) {
      selectedAya = aya;
      var dis = (sura - selectedSura).abs();
      gotoSura(sura, dis > 3 ? 0 : 400);
      // gotoAya(aya, 0);
    } else {
      gotoAya(aya, 800);
    }
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
      itemScrollController.jumpTo(index: aya);
    } else {
      itemScrollController.scrollTo(
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
}
