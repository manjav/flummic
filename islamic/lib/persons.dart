import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:islamic/models.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';

class PersonPage extends StatefulWidget {
  String title = "";
  @override
  PersonPageState createState() => PersonPageState();
}

class PersonPageState extends State<PersonPage>
    with SingleTickerProviderStateMixin {
  AnimationController fabAnimController;

  String title;
  List<String> items;
  Map<String, Person> persons;

  @override
  void initState() {
    super.initState();
    // widget.title = AppLocalizations.of(context).fab_tafsir;
    fabAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    items = <String>[];
    items.addAll(Prefs.reciters);
    title = AppLocalizations.of(context).recitation_title;
    persons = Configs.instance.reciters;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(title),
            actions: [
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: () => Navigator.pop(context),
              )
            ],
            automaticallyImplyLeading: false,
          ),
          body: ReorderableListView(
              children: <Widget>[
                for (int i = 0; i < items.length; i++)
                  ListTile(
                    key: Key('$i'),
                    // tileColor: items[index].isOdd ? oddItemColor : evenItemColor,

                    trailing: CircleAvatar(
                      backgroundImage: AssetImage('images/icon.png'),
                    ),
                    title: Text(
                      persons[items[i]].name,
                    ),
                    subtitle: Text(
                      "${persons[items[i]].mode} ${persons[items[i]].flag}",
                    ),
                    leading: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => print("object"),
                    ),
                  ),
              ],
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = items.removeAt(oldIndex);
                  items.insert(newIndex, item);
                  Prefs.reciters = items;
                });
              }),
          floatingActionButton: SpeedDial(
            child: AnimatedIcon(
              icon: AnimatedIcons.add_event,
              progress: fabAnimController,
            ),
            openBackgroundColor: Colors.redAccent,
            closedBackgroundColor: Colors.redAccent,
            // closedForegroundColor: Colors.black,
            // labelsStyle: /* Your label TextStyle goes here */,
            // controller: /* Your custom animation controller goes here */,
            onPressed: handleOnPressed,
            speedDialChildren: <SpeedDialChild>[
              SpeedDialChild(
                child: Icon(
                  Icons.arrow_back,
                ),
                foregroundColor: Colors.black,
                // backgroundColor: Colors.red,
                label: AppLocalizations.of(context).fab_quran,
                onPressed: () => speedChildPressed(0),
              ),
              SpeedDialChild(
                child: Icon(Icons.arrow_back),
                foregroundColor: Colors.black,
                // backgroundColor: Colors.yellow,
                label: AppLocalizations.of(context).fab_translate,
                onPressed: () => speedChildPressed(1),
              ),
              SpeedDialChild(
                child: Icon(Icons.arrow_back),
                foregroundColor: Colors.black,
                // backgroundColor: Colors.green,
                label: AppLocalizations.of(context).fab_tafsir,
                onPressed: () => speedChildPressed(2),
              ),
              //  Your other SpeeDialChildren go here.
            ],
          ),
        ));
  }

  void handleOnPressed(bool isOpen) {
    setState(() {
      isOpen ? fabAnimController.forward() : fabAnimController.reverse();
    });
  }

  void speedChildPressed(int i) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PersonListPage()));
  }
}

class PersonListPage extends StatefulWidget {
  String title = "";
  @override
  PersonListPageState createState() => PersonListPageState();
}

// _______________________________________________________________________-

class PersonListPageState extends State<PersonListPage> {
  List<Person> persons = <Person>[];
  List<Person> defaultPersons;

  Widget appBarTitle;
  Icon searchIcon = new Icon(Icons.search);
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    persons = defaultPersons = Configs.instance.reciters.values.toList();
    searchController.addListener(() {
      setState(() => persons = search(searchController.text));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: appBarTitle, actions: [
          IconButton(
            icon: searchIcon,
            onPressed: onSearchPressed,
          )
        ]),
        body: defaultPersons == null
            ? Center()
            : ListView.builder(
                itemBuilder: personItemBuilder,
                itemCount: persons.length,
              ));
  }

  void onSearchPressed() {
    setState(() {
      if (searchIcon.icon == Icons.search) {
        searchIcon = Icon(Icons.close);
        appBarTitle = TextField(
          controller: searchController,
          decoration: new InputDecoration(
              prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        searchIcon = new Icon(Icons.search);
        appBarTitle = Center();
        persons = search("");
        searchController.clear();
      }
    });
  }

  List<Person> search(String pattern) {
    if (pattern.isEmpty) return defaultPersons;
    return defaultPersons.where((p) => p.name.indexOf(pattern) > -1).toList();
  }

  Widget personItemBuilder(BuildContext context, int index) {
    var p = persons[index];
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('images/icon.png'),
          ),
          title: Text(
            p.name,
          ),
          subtitle: Text(
            "${p.mode} ${p.flag} ${p.size}",
          )),
    );
  }
}
