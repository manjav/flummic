import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islamic/models.dart';
import 'package:islamic/pages/home.dart';
import '../utils/localization.dart';

class IndexPage extends StatefulWidget {
  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  Widget appBarTitle;
  Icon searchIcon = new Icon(Icons.search);
  TextEditingController searchController = TextEditingController();

  ThemeData theme;
  TextStyle uthmaniStyle;
  TextStyle suraStyle = TextStyle(fontFamily: 'SuraNames', fontSize: 32);

  final _toolbarHeight = 56.0;
  double toolbarHeight = 0;
  double startScrollBarIndicator = 0;

  ScrollController suraListController;

  List<Sura> suras;

  String lastSort;

  @override
  void initState() {
    super.initState();

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
    uthmaniStyle = TextStyle(
        fontFamily: 'Uthmani', fontSize: 20, height: 2, wordSpacing: 2);
    return Scaffold(
        appBar: AppBar(
            title: appBarTitle,
            toolbarHeight: toolbarHeight,
            elevation: 0,
            actions: [
              IconButton(
                icon: searchIcon,
                onPressed: onSearchPressed,
              )
            ]),
        body: Stack(children: [
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
        ]));
  }

  Widget suraItemBuilder(context, int index) {
    var sura = suras[index];
    return Container(
        color: index % 2 == 0 ? theme.backgroundColor : theme.cardColor,
        child: GestureDetector(
            onTap: () => setState(() => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(index, 0)),
                )),
            child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                child: Row(
                  children: [
                    Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: sura.type == 0 ? Colors.blue : Colors.amber),
                        child: Align(
                            heightFactor: 0.8,
                            child: Text("${sura.index + 1}",
                                style: uthmaniStyle))),
                    SizedBox(width: 8, height: 48),
                    Expanded(
                      child: Text("${String.fromCharCode(sura.index + 13)}",
                          style: suraStyle, textAlign: TextAlign.right),
                    ),
                    getText(sura.order),
                    getText(sura.ayas),
                    getText(sura.page)
                  ],
                ))));
  }

  Container getText(int value) {
    return Container(
        width: 64,
        height: 24,
        alignment: Alignment.center,
        child: Text("$value", style: uthmaniStyle));
  }

  GestureDetector getHeader(String value) {
    return GestureDetector(
        onTap: () {
          if (lastSort == value) {
            suras = suras.reversed.toList();
          } else {
            lastSort = value;
            suras.sort((Sura l, Sura r) {
              if (value == "ayas")
                return l.ayas.compareTo(r.ayas);
              else if (value == "order")
                return l.order.compareTo(r.order);
              else if (value == "page")
                return l.page.compareTo(r.page);
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
                  Text("${value}_l".l()),
                  Positioned(
                    child: Icon(Icons.arrow_drop_down),
                    top: 24,
                  )
                ])));
  }

  void onSearchPressed() {}
}
