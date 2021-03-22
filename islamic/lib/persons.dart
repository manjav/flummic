import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:islamic/models.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';

class PersonPage extends StatefulWidget {
  static List<String> recitationModes = [
    "murat_t",
    "treci_t",
    "mujaw_t",
    "mualm_t"
  ];
  static List<String> translationModes = ["quran_t", "trans_t", "tafsi_t"];

  String title = "";
  @override
  PersonPageState createState() => PersonPageState();
}

class PersonPageState extends State<PersonPage>
    with SingleTickerProviderStateMixin {
  AnimationController fabAnimController;

  List<String> modes;
  bool isRecitationMode;
  List<String> prefsPersons;
  Map<String, Person> configPersons;

  @override
  void initState() {
    super.initState();
    // widget.title = AppLocalizations.of(context).fab_tafsir;
    isRecitationMode = true;
    prefsPersons = <String>[];
    prefsPersons.addAll(isRecitationMode ? Prefs.reciters : Prefs.translators);
    configPersons = isRecitationMode
        ? Configs.instance.reciters
        : Configs.instance.translators;
    fabAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    modes = PersonPage.recitationModes;
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
                for (int i = 0; i < prefsPersons.length; i++)
                  ListTile(
                    key: Key('$i'),
                    // tileColor: items[index].isOdd ? oddItemColor : evenItemColor,

                    trailing: CircleAvatar(
                      backgroundImage: AssetImage('images/icon.png'),
                    ),
                    title: Text(
                      configPersons[prefsPersons[i]].name,
                    ),
                    subtitle: Text(
                      "${configPersons[prefsPersons[i]].mode} ${configPersons[prefsPersons[i]].flag}",
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
                  final item = prefsPersons.removeAt(oldIndex);
                  prefsPersons.insert(newIndex, item);
                  Prefs.reciters = prefsPersons;
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
              for (int i = 0; i < modes.length; i++)
              SpeedDialChild(
                child: Icon(
                  Icons.arrow_back,
                ),
                foregroundColor: Colors.black,
                // backgroundColor: Colors.red,
                label: AppLocalizations.of(context).fab_quran,
                  onPressed: () => speedChildPressed(modes[i]),
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

  void speedChildPressed(String mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PersonListPage(
              isRecitationMode, mode, prefsPersons, configPersons)),
    ).then((value) => setState(() {}));
  }
}

// _______________________________________________________________________-

class PersonListPage extends StatefulWidget {
  String title = "";
  String mode;
  bool isRecitationMode;
  List<String> prefsPersons;
  Map<String, Person> configPersons;
  PersonListPage(
      this.isRecitationMode, this.mode, this.prefsPersons, this.configPersons)
      : super();

  @override
  PersonListPageState createState() => PersonListPageState();
}

class PersonListPageState extends State<PersonListPage> {
  List<Person> defaultPersons;
  List<Person> persons = <Person>[];

  Widget appBarTitle;
  Icon searchIcon = new Icon(Icons.search);
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    defaultPersons = <Person>[];
    persons = defaultPersons = widget.configPersons.values
        .where((p) =>
            p.mode == widget.mode && widget.prefsPersons.indexOf(p.path) <= -1)
        .toList();

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
