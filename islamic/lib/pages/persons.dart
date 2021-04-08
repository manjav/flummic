import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;
import '../buttons.dart';
import '../utils/localization.dart';
import '../models.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import '../main.dart';

class PersonPage extends StatefulWidget {
  static List<String> soundModes = ["murat_t", "treci_t", "mujaw_t", "muall_t"];
  static List<String> textModes = ["quran_t", "trans_t", "tafsi_t"];
  final PType type;
  PersonPage(this.type) : super();
  @override
  PersonPageState createState() => PersonPageState();
}

class PersonPageState extends State<PersonPage>
    with SingleTickerProviderStateMixin {
  AnimationController fabController;

  String title = "";
  List<String> modes;
  Map<String, Person> configPersons;

  @override
  void initState() {
    super.initState();
    var t = widget.type == PType.text;
    title = (t ? "page_texts" : "page_sounds").l();
    configPersons = t ? Configs.instance.texts : Configs.instance.sounds;
    fabController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    modes = t ? PersonPage.textModes : PersonPage.soundModes;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
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
              children: personItems(),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) newIndex -= 1;
                  final item = Prefs.persons[widget.type].removeAt(oldIndex);
                  Prefs.persons[widget.type].insert(newIndex, item);
                  Prefs.instance.setStringList(
                      widget.type.toString(), Prefs.persons[widget.type]);
                });
              }),
          floatingActionButton: SpeedDial(
            child: AnimatedIcon(
              icon: AnimatedIcons.add_event,
              progress: fabController,
            ),
            openBackgroundColor: theme.primaryColor,
            closedBackgroundColor: theme.primaryColor,
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
                  label: modes[i].l(),
                  onPressed: () => speedChildPressed(modes[i]),
                ),
              //  Your other SpeeDialChildren go here.
            ],
          ),
        ));
  }

  void removePerson(Person p) {
    Prefs.removePerson(p.type, p.path);
    setState(() => p.deselect());
  }

  void handleOnPressed(bool isOpen) {
    setState(() {
      isOpen ? fabController.forward() : fabController.reverse();
    });
  }

  void speedChildPressed(String mode) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PersonListPage(widget.type, mode, configPersons)));
  }

  List<Widget> personItems() {
    var items = <Widget>[];
    for (var t in Prefs.persons[widget.type]) {
      var p = configPersons[t];
      items.add(Directionality(
          key: Key(t),
          textDirection:
              Bidi.isRtlLanguage(MyApp.of(context).locale.languageCode)
                  ? TextDirection.rtl
                  : TextDirection.ltr,
          child: ListTile(
            leading: Avatar(t, 24),
            title: Text(p.name),
            subtitle: Text("${p.mode.l()} ${(p.flag + '_fl').l()}"),
            trailing: IconButton(
                icon: Icon(Icons.delete), onPressed: () => removePerson(p)),
          )));
    }
    return items;
  }
}

// _______________________________________________________________________-

class PersonListPage extends StatefulWidget {
  final String title = "";
  final String mode;
  final PType type;
  final Map<String, Person> configPersons;
  PersonListPage(this.type, this.mode, this.configPersons) : super();

  @override
  PersonListPageState createState() => PersonListPageState();
}

class PersonListPageState extends State<PersonListPage> {
  List<Person> defaultPersons;
  List<Person> persons = <Person>[];

  Widget appBarTitle;
  Icon searchIcon = Icon(Icons.search);
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    defaultPersons = <Person>[];
    persons = defaultPersons = widget.configPersons.values
        .where((p) => p.mode == widget.mode)
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
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Search...'),
        );
      } else {
        searchIcon = Icon(Icons.search);
        appBarTitle = Center();
        persons = search("");
        searchController.clear();
      }
    });
  }

  List<Person> search(String pattern) {
    if (pattern.isEmpty) return defaultPersons;
    pattern = pattern.toLowerCase();
    return defaultPersons
        .where((p) => p.name.toLowerCase().indexOf(pattern) > -1)
        .toList();
  }

  Widget personItemBuilder(BuildContext context, int index) {
    var p = persons[index];
    var subtitle = "${p.mode.l()} ${(p.flag + '_fl').l()}";
    if (widget.type == PType.text) {
      String size;
      if (p.size > 1048576)
        size = (p.size / 1048576).floor().n() + " " + "mbyte_t".l();
      else
        size = (p.size / 1024).floor().n() + " " + "kbyte_t".l();
      subtitle += " , $size";
    }
    return GestureDetector(
      onTap: () => selectPerson(p),
      child: ListTile(
        leading: Avatar(p.path, 24),
        title: Text(p.name),
        subtitle: Text(subtitle),
        trailing: Stack(
          alignment: Alignment.center,
          children: [
            if (p.state == PState.downloading)
              CircularProgressIndicator(
                strokeWidth: 2,
                value: p.progress,
              ),
            downloadIcon(context, p.state)
          ],
        ),
      ),
    );
  }

  void selectPerson(Person p) {
    switch (p.state) {
      case PState.selected:
        p.deselect();
        break;
      case PState.ready:
      case PState.waiting:
        p.select(() {
          Navigator.pop(context);
          setState(() {});
        }, (double p) {
          setState(() {});
        }, (String e) {
          print(e);
          setState(() {});
        });
        break;
      default:
        p.cancelLoading();
    }
    setState(() {});
  }

  Icon downloadIcon(BuildContext context, PState state) {
    switch (state) {
      case PState.ready:
        return Icon(Icons.radio_button_off);
      case PState.selected:
        return Icon(Icons.check_circle_outline_outlined);
      default:
        return Icon(Icons.cloud_download);
    }
  }
}
