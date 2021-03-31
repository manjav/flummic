import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islamic/models.dart';
import 'package:islamic/pages/home.dart';

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

  List<Sura> get suras => Configs.instance.metadata.suras;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    uthmaniStyle = TextStyle(
        fontFamily: 'Uthmani', fontSize: 20, height: 2, wordSpacing: 2);
    return Scaffold(
        appBar: AppBar(title: appBarTitle, actions: [
          IconButton(
            icon: searchIcon,
            onPressed: onSearchPressed,
          )
        ]),
        body: ListView.builder(
          itemBuilder: suraItemBuilder,
          itemCount: suras.length,
        ));
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
                            child: Text("${index + 1}", style: uthmaniStyle))),
                    SizedBox(width: 8, height: 48),
                    Expanded(
                      child: Text("${String.fromCharCode(index + 13)}",
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
        width: 56,
        height: 24,
        alignment: Alignment.center,
        child: Text("$value", style: uthmaniStyle));
  }

  void onSearchPressed() {}
}
