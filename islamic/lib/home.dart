import 'package:flutter/material.dart';
import 'package:islamic/models.dart';

class HomePage extends StatefulWidget {
  String title = "Sura 1";
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PageController suraPageController;
  ScrollController ayasController;

  TextStyle textStyle = TextStyle(
      fontFamily: 'Uthmani', fontSize: 22, height: 2, letterSpacing: 2);
  int selectedAyaIndex;
  int currentAyaIndex = 0;

  int currentPageValue;
  List<String> ayas;

  void initState() {
    super.initState();
    suraPageController = PageController();
    suraPageController.addListener(() {
      var page = suraPageController.page.round();
      if (page != currentPageValue) {
        setState(() {
          // toolbarHeight = _toolbarHeight;
          currentPageValue = page;
          widget.title = "Sura ${page + 1}";
        });
  }
    });

    ayasController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
        ListView.builder(
            itemCount: ayas.length,
            itemBuilder: ayaItemBuilder,
            controller: ayasController);
  }

  Widget ayaItemBuilder(BuildContext context, int index) {
    currentAyaIndex = index;
    return
        Text(ayas[index],
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
            style: textStyle)
        ;
  }
}
