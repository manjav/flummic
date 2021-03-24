import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:islamic/models.dart';
import 'package:islamic/persons.dart';

import 'buttons.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _toolbarHeight = 56.0;
  PageController suraPageController;
  ScrollController ayaScrollController;
  String title = Configs.instance.metadata.suras[0].name;

  // TextStyle cubicStyle = TextStyle(fontFamily: 'CubicSans');
  TextStyle textStyle = TextStyle(
      fontFamily: 'Uthmani', fontSize: 22, height: 2, letterSpacing: 2);
  TextStyle textStyleLight = TextStyle(
      fontFamily: 'Uthmani',
      fontSize: 22,
      height: 2,
      letterSpacing: 2,
      color: Colors.white);
  // int selectedAyaIndex;
  int currentAyaIndex = 0;
  int currentPageValue;
  double toolbarHeight;
  double startScrollBarIndicator = 0;

  void initState() {
    super.initState();
    toolbarHeight = _toolbarHeight;
    suraPageController = PageController();
    suraPageController.addListener(() {
      var page = suraPageController.page.round();
      if (page != currentPageValue) {
        setState(() {
          toolbarHeight = _toolbarHeight;
          currentPageValue = page;
          title = Configs.instance.metadata.suras[page].name;
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
    return new Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
            appBar: AppBar(
              toolbarHeight: toolbarHeight,
              toolbarOpacity: toolbarHeight / _toolbarHeight,
              centerTitle: true,
              title: Text(title, style: textStyle),
            ),
            body: PageView.builder(
                reverse: true,
                itemCount: Configs.instance.quran.length,
                itemBuilder: suraPageBuilder,
                controller: suraPageController),
            floatingActionButton: Container(
                transform: Matrix4.identity()
                  ..translate(0.1, _toolbarHeight * 2 - toolbarHeight * 2),
                child: FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PersonPage(true)))))));
  }

  Widget suraPageBuilder(BuildContext context, int p) {
    var ayas = Configs.instance.quran[p];
    return DraggableScrollbar.arrows(
        labelTextBuilder: (offset) {
          return ayas.length < 10
              ? null
              : Text(
                  "${currentAyaIndex + 1}",
                  style: textStyleLight,
                );
        },
        labelConstraints: BoxConstraints.tightFor(width: 80.0, height: 30.0),
        backgroundColor: Theme.of(context).primaryColorDark,
        controller: ayaScrollController,
        child: ListView.builder(
            itemCount: ayas.length,
            itemBuilder: (BuildContext ctx, i) => ayaItemBuilder(p, i),
            controller: ayaScrollController));
  }

  Widget ayaItemBuilder(int position, int index) {
    currentAyaIndex = index;
    return
        /*GestureDetector(
        onTap: () => setState(() {
              selectedAyaIndex = index;
            }),
        child: 
        */
        // color: index == selectedAyaIndex ? Colors.white70 : Colors.white,
        Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 12),
            child: Column(children: textsProvider(position, index)));
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

    if (Prefs.texts.indexOf("ar.uthmanimin") > -1)
      rows.add(Text("${aya + 1}. ${Configs.instance.quran[sura][aya]}",
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          style: textStyle));

    for (var path in Prefs.texts) {
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
                ? "\t\t\t\t\t\t\t\t${aya + 1}. ${texts.data[sura][aya]}"
                : "\t\t\t\t\t\t\t\t${texts.data[sura][aya]}",
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
      rows.add(SizedBox(height: 12));
    }
    rows.add(Divider(color: Colors.black45));
    return rows;
  }
}
