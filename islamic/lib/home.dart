import 'package:draggable_scrollbar/draggable_scrollbar.dart';
import 'package:flutter/material.dart';
import 'package:islamic/models.dart';
import 'package:islamic/persons.dart';

import 'buttons.dart';

class HomePage extends StatefulWidget {
  String title = Configs.instance.metadata.suras[0].name;
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _toolbarHeight = 56.0;
  PageController suraPageController;
  ScrollController ayaScrollController;

  TextStyle cubicStyle = TextStyle(fontFamily: 'CubicSans');
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
          widget.title = Configs.instance.metadata.suras[page].name;
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
              title: Text(widget.title, style: textStyle),
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
                            builder: (context) => PersonPage()))))));
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
    var aya = Configs.instance.quran[position][index];
    currentAyaIndex = index;
    return
        /*GestureDetector(
        onTap: () => setState(() {
              selectedAyaIndex = index;
            }),
        child: 
        */
        Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            // color: index == selectedAyaIndex ? Colors.white70 : Colors.white,
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                child: Column(children: <Widget>[
                  Row(
                    children: [
                      CircleButton(icon: Icons.bookmark),
                      SizedBox(width: 8),
                      CircleButton(icon: Icons.share),
                      Spacer(),
                      CircleButton(text: (index + 1).toString()),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(aya,
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      style: textStyle),
/*                   ListTile(
                    trailing: CircleAvatar(
                      backgroundImage: AssetImage('images/icon.png'),
                    ),
                    title: Text(
                      Configs.instance.translators["fa.fooladvand"]
                          .data[position][index],
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                    ),
                  ), */
                  ListTile(
                    trailing: CircleAvatar(
                      backgroundImage: AssetImage('images/icon.png'),
                    ),
                    title: Text(
                      Configs.instance.translators["fa.fooladvand"]
                          .data[position][index],
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      style: cubicStyle,
                    ),
                  )
                ])
                // ),
                ));
  }
}
