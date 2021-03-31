import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;
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
  PageController suraPageController;
  ScrollController ayaScrollController;
  String title = String.fromCharCode(13);

  TextStyle suraStyle = TextStyle(fontFamily: 'SuraNames', fontSize: 32);
  TextStyle textStyle;
  TextStyle textStyleLight;
  // int selectedAyaIndex;
  int currentAyaIndex = 0;
  int currentPageValue;
  double toolbarHeight;
  double startScrollBarIndicator = 0;
  bool hasQuranText = false;
  ThemeData theme;

  void initState() {
    super.initState();
    hasQuranText = Prefs.persons[PType.text].indexOf("ar.uthmanimin") > -1;
    toolbarHeight = _toolbarHeight;
    suraPageController = PageController(keepPage: true, initialPage: 12);
    suraPageController.addListener(() {
      var page = suraPageController.page.round();
      if (page != currentPageValue) {
        setState(() {
          toolbarHeight = _toolbarHeight;
          currentPageValue = page;
          title = String.fromCharCode(page + 13);
        });
      }
    });

    ayaScrollController = ScrollController();
    ayaScrollController.addListener(() {
      var changes =
          startScrollBarIndicator - ayaScrollController.position.pixels;
      startScrollBarIndicator = ayaScrollController.position.pixels;
      var h = (toolbarHeight + changes).clamp(0.0, _toolbarHeight);
      if (toolbarHeight != h) {
        toolbarHeight = h;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    var app = MyApp.of(context);
    textStyle = TextStyle(
        fontFamily: 'Uthmani', fontSize: 20, height: 2, wordSpacing: 2);
    textStyleLight = TextStyle(
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
                    onPressed: () {},
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
                      child: Text(title, style: suraStyle),
                      height: _toolbarHeight,
                    )),
                footer()
              ],
            )));
  }

  Widget suraPageBuilder(BuildContext context, int p) {
    var len = Configs.instance.metadata.suras[p].ayas;
    return DraggableScrollbar.arrows(
        labelTextBuilder: (offset) {
          return len < 10
              ? null
              : Text(
                  "${currentAyaIndex + 1}",
                  style: textStyleLight,
                );
        },
        labelConstraints: BoxConstraints.tightFor(width: 80.0, height: 30.0),
        backgroundColor: theme.cardColor,
        controller: ayaScrollController,
        child: ListView.builder(
            padding: EdgeInsets.only(top: _toolbarHeight + 10, bottom: 24),
            itemCount: len,
            itemBuilder: (BuildContext ctx, i) => ayaItemBuilder(p, i),
            controller: ayaScrollController));
  }

  Widget ayaItemBuilder(int position, int index) {
    currentAyaIndex = index;
    return Container(
        color: index % 2 == 0 ? theme.backgroundColor : theme.cardColor,
        child: GestureDetector(
            onTap: () => setState(() {
                  // var tween = Tween<double>(begin: -200, end: 0);
                  toolbarHeight = _toolbarHeight;
                }),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
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
          style: textStyle));

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
          ),
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
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
            transform: Matrix4.identity()
              ..translate(0.1, _toolbarHeight * 2 - toolbarHeight * 2),
            height: 56,
            child: Row(
              children: [
                IconButton(
                    icon: Icon(Icons.add_comment_outlined,
                        color: theme.appBarTheme.iconTheme.color),
                    onPressed: () => footerPressed(PType.text)),
                IconButton(
                    icon: Icon(Icons.headset_sharp,
                        color: theme.appBarTheme.iconTheme.color),
                    onPressed: () => footerPressed(PType.sound)),
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
}
