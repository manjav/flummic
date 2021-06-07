import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:islamic/models.dart';
import 'package:islamic/utils/localization.dart';
import 'package:islamic/widgets/texts.dart';
import 'package:share/share.dart';

import '../main.dart';

class AyaDetails extends StatefulWidget {
  final int sura, aya;
  final Function(String, int) updater;
  AyaDetails(this.sura, this.aya, this.updater);

  @override
  State<StatefulWidget> createState() => AyaDetailsState();
}

class AyaDetailsState extends State<AyaDetails> {
  bool hasNote = false;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    hasNote = Prefs.hasNote(widget.sura, widget.aya)!;
    return Container(
        height: 160,
        child: Stack(alignment: Alignment.topCenter, children: [
          Generics.draggable(theme),
          Positioned(
            top: 20,
            child: Text(
              "${'sura_l'.l()} ${Configs.instance.metadata.suras[widget.sura].title} - ${'aya_l'.l()} ${(widget.aya + 1).n()}",
              style: theme.textTheme.headline5,
            ),
          ),
          Positioned(
              right: 4,
              bottom: 4,
              child: Row(textDirection: TextDirection.ltr, children: [
                getButton(theme, Icons.share, "share"),
                getButton(theme, getNoteIcon(), "note"),
                getButton(theme, Icons.play_circle_fill, "play")
              ]))
        ]));
  }

  IconButton getButton(ThemeData theme, IconData icon, String type) {
    return IconButton(
        padding: EdgeInsets.all(28),
        icon: Icon(icon, color: theme.textTheme.bodyText1!.color),
        onPressed: () => onPressed(theme, type));
  }

  void onPressed(ThemeData theme, String type) {
    var s = widget.sura;
    var a = widget.aya;
    switch (type) {
      case "share":
        var subject =
            "${'sura_l'.l()} ${Configs.instance.metadata.suras[s].title} ${'aya_l'.l()} ${(a + 1).n()}\n${'share_sign'.l()} ${'app_title'.l()}";
        var text = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\n" +
            Configs.instance.quran[s][a];
        if (Prefs.persons[PType.text]!.length > 1) {
          var p = Configs.instance.texts[Prefs.persons[PType.text]![1]];
          text += "\n\n${p!.data![s][a]}\n\n${'trans_t'.l()} ${p.name}";
        }
        text += "\n\n$subject";
        Share.share(text, subject: subject);
        Navigator.of(context).pop();
        break;

      case "note":
        if (!hasNote)
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  Generics.editNote(context, theme, s, a, widget.updater));
        setState(() {
          hasNote ? Prefs.removeNote(s, a) : Prefs.addNote(s, a, "");
        });
        widget.updater("note", 0);
        break;

      default:
        widget.updater(
            "play",
            Configs
                .instance.navigations["sura"]![widget.sura][widget.aya].index);
        // MyApp.of(context)!.player.select(widget.sura, widget.aya, 0, true);
        Navigator.of(context).pop();
        break;
    }
  }

  IconData getNoteIcon() {
    if (hasNote) return Icons.bookmark;
    return Icons.bookmark_border;
  }
}

class Settings extends StatefulWidget {
  final Function updater;
  Settings(this.updater);

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  int themeMode = Prefs.themeMode;
  @override
  Widget build(BuildContext context) {
    var app = MyApp.of(context)!;
    var theme = Theme.of(context);
    var p = 24.0;
    var isRtl = Bidi.isRtlLanguage(app.locale!.languageCode);
    var queryData = MediaQuery.of(context);
    var config = Configs.instance.buildConfig;
    return Container(
        height: 500,
        child: MediaQuery(
          data: queryData.copyWith(
              textScaleFactor: queryData.textScaleFactor * Prefs.textScale),
          child: Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: Stack(alignment: Alignment.topCenter, children: [
                Generics.draggable(theme),
                Generics.text(theme, "theme_mode".l(), 48, isRtl ? p : null,
                    isRtl ? null : p),
                Positioned(
                    top: 40,
                    left: isRtl ? p : null,
                    right: isRtl ? null : p,
                    child: DropdownButton<int>(
                      value: themeMode,
                      style: theme.textTheme.caption,
                      onChanged: (int? newValue) {
                        themeMode = newValue!;
                        app.setTheme(ThemeMode.values[themeMode]);
                        Navigator.pop(context);
                      },
                      items: <int>[0, 1, 2]
                          .map<DropdownMenuItem<int>>(
                              (int value) => DropdownMenuItem<int>(
                                    value: value,
                                    child: Text("theme_$value".l()),
                                  ))
                          .toList(),
                    )),
                Generics.text(theme, "select_loc".l(), 118, isRtl ? p : null,
                    isRtl ? null : p),
                Positioned(
                    top: 110,
                    left: isRtl ? p : null,
                    right: isRtl ? null : p,
                    child: DropdownButton<Locale>(
                      value: app.locale,
                      style: theme.textTheme.caption,
                      onChanged: (Locale? v) {
                        Localization.change(v!.languageCode, onDone: (l) {
                          MyApp.of(context)!.setLocale(l);
                          setState(() {});
                        });
                      },
                      items: MyApp.supportedLocales
                          .map<DropdownMenuItem<Locale>>(
                              (Locale value) => DropdownMenuItem<Locale>(
                                    value: value,
                                    child: Text(value.languageCode.f()),
                                  ))
                          .toList(),
                    )),
                Generics.text(theme, "tsize_l".l(), 188, isRtl ? p : null,
                    isRtl ? null : p),
                Positioned(
                    top: 220,
                    right: p - 16,
                    left: p - 16,
                    child: Slider(
                        autofocus: true,
                        min: 0.85,
                        max: 1.3,
                        value: Prefs.textScale,
                        divisions: 3,
                        onChanged: (double value) {
                          setState(() {
                            Prefs.instance.setDouble("textScale", value);
                          });
                          widget.updater();
                        })),
                Positioned(
                    top: 260,
                    right: -p * 2,
                    left: -p * 2,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (var i = 0; i < 4; i++)
                            Text("tsize_$i".l(), style: theme.textTheme.caption)
                        ])),
                Generics.text(theme, "navi_mode".l(), 320, isRtl ? p : null,
                    isRtl ? null : p),
                Positioned(
                    top: 310,
                    left: isRtl ? p : null,
                    right: isRtl ? null : p,
                    child: DropdownButton<String>(
                      value: Prefs.naviMode,
                      style: theme.textTheme.caption,
                      onChanged: (String? newValue) {
                        Prefs.instance.setString("naviMode", newValue!);
                        setState(() {});
                        widget.updater();
                      },
                      items: <String>["sura", "juze", "page"]
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text("navi_$value".l()),
                                  ))
                          .toList(),
                    )),
                Generics.text(theme, "select_font".l(), 390, isRtl ? p : null,
                    isRtl ? null : p),
                Positioned(
                    top: 380,
                    left: isRtl ? p : null,
                    right: isRtl ? null : p,
                    child: DropdownButton<String>(
                      value: Prefs.font,
                      style: theme.textTheme.caption,
                      onChanged: (String? newValue) {
                        Prefs.instance.setString("font", newValue!);
                        setState(() {});
                        widget.updater();
                      },
                      items: <String>["mequran", "scheherazade"]
                          .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Texts.quran(
                                        "",
                                        "قُل إِنَّ هُدَى ۚ  اللَّهِ  ۖ  هُوَ الهُدىٰ ۗ ",
                                        "",
                                        TextStyle(
                                            fontFamily: value,
                                            fontSize: 18,
                                            color: theme
                                                .textTheme.bodyText1!.color)),
                                  ))
                          .toList(),
                    )),
                Positioned(
                    bottom: p,
                    left: isRtl ? p : null,
                    right: isRtl ? null : p,
                    child: Text(
                        "${'app_title'.l()}  ${'app_ver'.l()} ${config!.packageInfo!.version.n()}  (${config.target})",
                        style: theme.textTheme.caption))
              ])),
        ));
  }
}

class Generics {
  static Widget draggable(ThemeData theme) {
    return Positioned(
        top: 10,
        width: 24,
        height: 5,
        child: Container(
          decoration: BoxDecoration(
              color: theme.textTheme.bodyText1!.color,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(4))),
        ));
  }

  static Widget text(
      ThemeData theme, String text, double? top, double? right, double? left) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Text(
        text,
        style: theme.textTheme.subtitle1,
      ),
    );
  }

  static Widget editNote(BuildContext context, ThemeData theme, int sura,
      int aya, Function? updater) {
    final textController =
        TextEditingController(text: Prefs.getNote(sura, aya));
    return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        titlePadding: EdgeInsets.fromLTRB(16, 40, 16, 8),
        // scrollable: true,
        title: Container(
            width: 320,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                    top: -72,
                    width: 64,
                    height: 64,
                    child: Container(
                        decoration: BoxDecoration(
                          color: theme.bottomAppBarColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bookmark,
                          size: 32,
                          color: theme.primaryColor,
                        ))),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        autofocus: true,
                        controller: textController,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'note_hint'.l(),
                        ),
                        minLines: 1, //Normal textInputField will be displayed
                        maxLines: 6, //Normal textInputField will be displayed
                      ),
                      SizedBox(height: 8),
                      TextButton(
                        child: Text("save_l".l()),
                        onPressed: () {
                          updater?.call("note", 0);
                          Prefs.addNote(sura, aya, textController.text);
                          Navigator.of(context).pop();
                        },
                      )
                    ])
              ],
            )));
  }

  static Future<void> confirm(BuildContext context,
      {String? title,
      String? text,
      String? acceptLabel,
      String? declineLabel,
      Function? onAccept,
      Function? onDecline,
      bool barrierDismissible = true}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? SizedBox() : Text(title),
          content: text == null ? SizedBox() : Text(text),
          actions: <Widget>[
            TextButton(
              child: Text(acceptLabel ?? "yes_l".l()),
              onPressed: () {
                onAccept?.call();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(declineLabel ?? "no_l".l()),
              onPressed: () {
                onDecline?.call();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /* static void toast(BuildContext context, ThemeData theme, String text) {
    showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
            backgroundColor: Color(0x66111111),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            titlePadding: EdgeInsets.fromLTRB(8, 6, 8, 8),
            // scrollable: true,
            title: Center(
              child: Text(
                text,
                style: theme.textTheme.caption,
              ),
            )));
  } */
}
