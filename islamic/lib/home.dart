import 'package:flutter/material.dart';
import 'package:islamic/models.dart';

class HomePage extends StatefulWidget {
  String title = "Sura 1";
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PageController suraPageController;
  TextStyle textStyle = TextStyle(
      fontFamily: 'Uthmani', fontSize: 22, height: 2, letterSpacing: 2);
  int selectedAyaIndex;
  int currentAyaIndex = 0;

  int currentPageValue;

  void initState() {
    super.initState();
    suraPageController = PageController();
    suraPageController.addListener(() {
      var page = suraPageController.page.round();
      if (page != currentPageValue) {
        setState(() {
          currentPageValue = page;
          widget.title = "Sura ${page + 1}";
        });
  }
    });
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
    var ayas = Configs.instance.quran[position];

    return Center(child: Text(ayas[0]));
  }
}
