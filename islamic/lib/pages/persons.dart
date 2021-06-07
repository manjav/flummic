import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../buttons.dart';
import '../models.dart';
import '../utils/localization.dart';

class PersonPage extends StatefulWidget {
  static List<String> soundModes = ["mujaw_t", "treci_t", "murat_t"]; //muall_t
  static List<String> textModes = ["tafsi_t", "trans_t", "quran_t"];
  final PType type;
  PersonPage(this.type) : super();
  @override
  PersonPageState createState() => PersonPageState();
}

class PersonPageState extends State<PersonPage>
    with SingleTickerProviderStateMixin {
  String title = "";
  List<String>? modes;
  Map<String, Person>? configPersons;
  AnimationController? removeAnimation;

  @override
  void initState() {
    super.initState();
    var t = widget.type == PType.text;
    title = (t ? "page_texts" : "page_sounds").l();
    configPersons = t ? Configs.instance.texts : Configs.instance.sounds;
    modes = t ? PersonPage.textModes : PersonPage.soundModes;
    removeAnimation = AnimationController(vsync: this);
    removeAnimation!.addListener(() => setState(() {}));
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
                    children: _personItems(context, theme),
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
                    for (int i = 0; i < modes!.length; i++)
                      SpeedDialChild(
                          labelWidget: Text(modes![i].l(),
                              textAlign: TextAlign.right,
                              style: theme.textTheme.bodyText1),
                          child: Icon(Icons.arrow_back),
                          backgroundColor:
                              theme.floatingActionButtonTheme.backgroundColor,
                          onTap: () => onSpeedChildTap(modes![i])),
                  ],
                ))));
  }

  void onSpeedChildTap(String mode) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PersonListPage(widget.type, mode, configPersons!)));
    setState(() {});
  }

  List<Widget> _personItems(BuildContext context, ThemeData theme) {
    var removable = _removable();
    var items = <Widget>[];
    for (var p in Prefs.persons[widget.type]!)
      items.add(_personItem(p, removable, theme));
    return items;
  }

  Widget _personItem(String p, bool removable, ThemeData theme) {
    var ps = configPersons![p];
    var color = theme.buttonTheme.colorScheme!.onSurface
        .withOpacity(!removable && ps!.state == PState.selected ? 0.4 : 1);
    return Directionality(
        key: Key(p),
        textDirection: Localization.dir,
        child: Stack(children: [
          ListTile(
              horizontalTitleGap: 8,
              contentPadding: EdgeInsets.only(left: 8, right: 8),
              leading: Avatar(p, 24),
              title: Text(ps!.title),
              subtitle: Text("${ps.mode!.l()} ${(ps.flag! + '_l').l()}")),
          ps.state == PState.removing
              ? Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    color: theme.backgroundColor.withOpacity(0.8),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("undo_b".l(), style: theme.textTheme.subtitle1),
                          SizedBox(height: 16),
                          LinearProgressIndicator(value: removeAnimation!.value)
                        ]),
                  ))
              : SizedBox(),
          Positioned(
              left: Localization.isRTL ? 8 : null,
              right: Localization.isRTL ? null : 8,
              top: 8,
              bottom: 8,
              child: IconButton(
                  icon: Icon(
                      ps.state == PState.removing
                          ? Icons.restore_from_trash
                          : Icons.delete,
                      color: color),
                  onPressed: () => _removePerson(context, ps)))
        ]));
  }

  bool _removable() {
    var numSelecteds = 0;
    for (var p in Prefs.persons[widget.type]!)
      if (configPersons![p]!.state == PState.selected) ++numSelecteds;
    return numSelecteds > 1;
  }

  void _removePerson(BuildContext context, Person p) {
    if (p.state == PState.removing) {
      p.cancelDeselect();
      setState(() {});
      return;
    }
    if (!_removable()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "empty_err".l(),
        textDirection: Localization.dir,
      )));
      return;
    }
    const duration = Duration(seconds: 3);
    removeAnimation!.value = 0;
    removeAnimation!
        .animateTo(1, duration: duration, curve: Curves.easeOutSine);
    p.deselect(duration, () => setState(() {}));
    setState(() {});
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
    var foreign = <Person>[];
    for (var p in widget.configPersons.values) {
      if (p.mode != widget.mode) continue;
      if (p.flag == Localization.languageCode)
        defaultPersons!.add(p);
      else
        foreign.add(p);
    }
    defaultPersons!.addAll(foreign);

    persons = defaultPersons!;
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
        .where((p) => p.name!.toLowerCase().indexOf(pattern) > -1)
        .toList();
  }

  Widget personItemBuilder(BuildContext context, int index) {
    var p = persons[index];
    var subtitle = "${p.mode!.l()} ${p.flag!.f()}";
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
        horizontalTitleGap: 8,
        contentPadding: EdgeInsets.only(left: 8, right: 8),
        leading: Avatar(p.path!, 24),
        title: Text(p.title),
        ),
        trailing: SizedBox(
            width: 48,
            child: Stack(
          alignment: Alignment.center,
          children: [
            if (p.state == PState.downloading)
              CircularProgressIndicator(
                strokeWidth: 2,
                value: p.progress,
              ),
            downloadIcon(context, p.state!)
          ],
            )),
      ),
    );
  }

  void selectPerson(Person p) {
    switch (p.state) {
      case PState.selected:
        p.deselect(null, null);
        break;
      case PState.ready:
      case PState.waiting:
        p.select(() {
          Navigator.pop(context);
          setState(() {});
        }, (double p) {
          setState(() {});
        }, (dynamic e) {
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
