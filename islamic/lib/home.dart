import 'package:flutter/material.dart';
import 'package:islamic/models.dart';

import 'buttons.dart';

class HomePage extends StatefulWidget {
  String title = "Sura 1";
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _toolbarHeight = 56.0;
  PageController suraPageController;
  ScrollController ayasController;

  TextStyle textStyle = TextStyle(
      fontFamily: 'Uthmani', fontSize: 22, height: 2, letterSpacing: 2);
  // int selectedAyaIndex;
  int currentAyaIndex = 0;
  int currentPageValue;
  List<String> ayas;
  bool isScrollingDown = false;
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
          widget.title = "Sura ${page + 1}";
        });
      }
    });

    ayasController = ScrollController();
    ayasController.addListener(() {
      var changes = startScrollBarIndicator - ayasController.position.pixels;
      startScrollBarIndicator = ayasController.position.pixels;
      var h = (toolbarHeight + changes).clamp(0.0, _toolbarHeight);
      if (toolbarHeight != h) {
        toolbarHeight = h;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            controller: suraPageController));
  }

  Widget suraPageBuilder(BuildContext context, int position) {
    ayas = Configs.instance.quran[position];

    return
        /* DraggableScrollbar.arrows(
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
        controller: ayasController,
        child: */
        ListView.builder(
            itemCount: ayas.length,
            itemBuilder: ayaItemBuilder,
            controller: ayasController);
  }

  Widget ayaItemBuilder(BuildContext context, int index) {
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
                  Text(ayas[index],
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      style: textStyle),
                  ListTile(
                    trailing: CircleAvatar(
                      backgroundImage: AssetImage('images/icon.png'),
                    ),
                    title: Text(
                      ayas[index],
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                    ),
                  )
                ])
                // ),
                ));
  }
}
