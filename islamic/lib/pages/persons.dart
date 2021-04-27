import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../buttons.dart';
import '../models.dart';
import '../utils/localization.dart';

class PersonPage extends StatefulWidget {
  static List<String> soundModes = ["murat_t", "treci_t", "mujaw_t"]; //muall_t
  static List<String> textModes = ["quran_t", "trans_t", "tafsi_t"];
  final PType type;
  PersonPage(this.type) : super();
  @override
  PersonPageState createState() => PersonPageState();
}

class PersonPageState extends State<PersonPage>
    with SingleTickerProviderStateMixin {
  String title = "";
  late List<String> modes;
  late Map<String, Person> configPersons;

  @override
  void initState() {
    super.initState();
    var t = widget.type == PType.text;
    title = (t ? "page_texts" : "page_sounds").l();
    configPersons = t ? Configs.instance.texts : Configs.instance.sounds;
    modes = t ? PersonPage.textModes : PersonPage.soundModes;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var queryData = MediaQuery.of(context);
    return MediaQuery(
        data: queryData.copyWith(
            textScaleFactor: queryData.textScaleFactor * Prefs.textScale),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text(title),
                  actions: [
                    Localization.isRTL
                        ? IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: () => Navigator.pop(context),
                          )
                        : SizedBox()
                  ],
                  leading: Localization.isRTL
                      ? SizedBox()
                      : IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                  automaticallyImplyLeading: false,
                ),
                body: ReorderableListView(
                    children: personItems(),
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) newIndex -= 1;
                        final item =
                            Prefs.persons[widget.type]!.removeAt(oldIndex);
                        Prefs.persons[widget.type]!.insert(newIndex, item);
                        Prefs.instance.setStringList(widget.type.toString(),
                            Prefs.persons[widget.type]!);
                      });
                    }),
                floatingActionButton: SpeedDial(
                  icon: Icons.add,
                  curve: Curves.easeOutExpo,
                  overlayColor: theme.backgroundColor,
                  overlayOpacity: 0.5,
                  tooltip: title,
                  heroTag: 'fab',
                  backgroundColor:
                      theme.floatingActionButtonTheme.backgroundColor,
                  children: [
                    for (int i = 0; i < modes.length; i++)
                      SpeedDialChild(
                          labelWidget: Text(modes[i].l(),
                              textAlign: TextAlign.right,
                              style: theme.textTheme.bodyText1),
                          child: Icon(Icons.arrow_back),
                          backgroundColor:
                              theme.floatingActionButtonTheme.backgroundColor,
                          onTap: () => onSpeedChildTap(modes[i])),
                  ],
                ))));
  }

  void removePerson(Person p) {
    Prefs.removePerson(p.type, p.path);
    setState(() => p.deselect());
  }

  void onSpeedChildTap(String mode) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PersonListPage(widget.type, mode, configPersons)));
    setState(() {});
  }

  List<Widget> personItems() {
    var items = <Widget>[];
    for (var t in Prefs.persons[widget.type]!) {
      var p = configPersons[t];
      items.add(Directionality(
          key: Key(t),
          textDirection: Localization.dir,
          child: ListTile(
            leading: Avatar(t, 24),
            title: Text(p!.title),
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
  List<Person>? defaultPersons;
  List<Person> persons = <Person>[];

  Widget? appBarTitle;
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
    var queryData = MediaQuery.of(context);
    return MediaQuery(
        data: queryData.copyWith(
            textScaleFactor: queryData.textScaleFactor * Prefs.textScale),
        child: Scaffold(
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
                  )));
  }

  void onSearchPressed() {
    setState(() {
      if (searchIcon.icon == Icons.search) {
        searchIcon = Icon(Icons.close);
        appBarTitle = TextField(
          autofocus: true,
          controller: searchController,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'search_in'.l()),
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
    if (pattern.isEmpty) return defaultPersons!;
    pattern = pattern.toLowerCase();
    return defaultPersons!
        .where((p) => p.name.toLowerCase().indexOf(pattern) > -1)
        .toList();
  }

  Widget personItemBuilder(BuildContext context, int index) {
    var p = persons[index];
    var subtitle = "${p.mode.l()} ${(p.flag + '_fl').l()}";
    if (widget.type == PType.text) {
      String size;
      if (p.size! > 5048576)
        size = (p.size! / 5048576).floor().n() + " " + "mbyte_t".l();
      else
        size = (p.size! / 5024).floor().n() + " " + "kbyte_t".l();
      subtitle += " , $size";
    }
    return GestureDetector(
      onTap: () => selectPerson(p),
      child: ListTile(
        leading: Avatar(p.path, 24),
        title: Text(p.title),
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
