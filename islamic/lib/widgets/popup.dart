import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:islamic/models.dart';
import 'package:islamic/utils/localization.dart';
import 'package:share/share.dart';

import '../main.dart';

class AyaDetails extends StatefulWidget {
  final int sura, aya;
  final Function updater;
  AyaDetails(this.sura, this.aya, this.updater);

  @override
  State<StatefulWidget> createState() => AyaDetailsState();
}

class AyaDetailsState extends State<AyaDetails> {
  String bookmark;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bookmark = Prefs.getNote(widget.sura, widget.aya);
    return Container(
        height: 160,
        child: Stack(alignment: Alignment.topCenter,
            // fit: StackFit.expand,
            // clipBehavior: Clip.none,
            children: [
              Generics.draggable(theme),
              Positioned(
                top: 20,
                child: Text(
                  "${'sura_l'.l()} ${Configs.instance.metadata.suras[widget.sura].title} - ${'verse_l'.l()} ${(widget.aya + 1).n()}",
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
        icon: Icon(icon, color: theme.textTheme.bodyText1.color),
        onPressed: () => onPressed(theme, type));
  }

  void onPressed(ThemeData theme, String type) {
    var s = widget.sura;
    var a = widget.aya;
    switch (type) {
      case "share":
        var subject =
            "${'sura_l'.l()} ${Configs.instance.metadata.suras[s].name} ${'verse_l'.l()} ${(a + 1).n()}\n${'share_sign'.l()} ${'app_title'.l()}";
        var text = "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ\n" +
            Configs.instance.quran[s][a];
        if (Prefs.persons[PType.text].length > 1) {
          var p = Configs.instance.texts[Prefs.persons[PType.text][1]];
          text += "\n\n${p.data[s][a]}\n\n${'trans_t'.l()} ${p.name}";
        }
        text += "\n\n$subject";
        Share.share(text, subject: subject);
        Navigator.of(context).pop();
        break;

      case "note":
        if (bookmark == null)
          showDialog(
              context: context,
              builder: (BuildContext context) =>
                  Generics.editNote(context, theme, s, a));
        setState(() {
          bookmark == null ? Prefs.addNote(s, a, "") : Prefs.removeNote(s, a);
        });
        widget.updater();
        break;

      default:
        MyApp.of(context).player.select(widget.sura, widget.aya, 0, true);
        Navigator.of(context).pop();
        break;
    }
  }

  IconData getNoteIcon() {
    if (bookmark == null)
      return Icons.bookmark_border;
    else if (bookmark == "")
      return Icons.bookmark;
    else
      return Icons.bookmark;
  }
}

class Settings extends StatefulWidget {
  final Function updater;
  Settings(this.updater);

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  int themeMode = Prefs.instance.getInt("themeMode");
  @override
  Widget build(BuildContext context) {
    var app = MyApp.of(context);
    var theme = Theme.of(context);
    var p = 24.0;
    var isRtl = Bidi.isRtlLanguage(app.locale.languageCode);
    var queryData = MediaQuery.of(context);

    return Container(
        height: 440,
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
                      onChanged: (int newValue) {
                        themeMode = newValue;
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
                      onChanged: (Locale newValue) {
                        Localization.change(context, newValue.languageCode);
                        setState(() {});
                      },
                      items: app.supportedLocales
                          .map<DropdownMenuItem<Locale>>(
                              (Locale value) => DropdownMenuItem<Locale>(
                                    value: value,
                                    child: Text("${value.languageCode}_fl".l()),
                                  ))
                          .toList(),
                    )),
                Generics.text(theme, "text_size".l(), 188, isRtl ? p : null,
                    isRtl ? null : p),
                Positioned(
                    top: 220,
                    right: p,
                    left: p,
                    child: Slider(
                        autofocus: true,
                        min: 0.85,
                        max: 1.3,
                        value: Prefs.textScale,
                        divisions: 3,
                        onChanged: (double value) {
                          setState(() {
                            Prefs.textScale = value;
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
                            Text("text_$i".l(), style: theme.textTheme.caption)
                        ])),
                Positioned(
                    bottom: p,
                    left: isRtl ? p : null,
                    right: isRtl ? null : p,
                    child: Text(
                        "${'app_title'.l()}  ${'app_ver'.l()} ${'1.0.1'.n()}",
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
              color: theme.textTheme.bodyText1.color,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(4))),
        ));
  }

  static Widget text(
      ThemeData theme, String text, double top, double right, double left) {
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

  static Widget editNote(
      BuildContext context, ThemeData theme, int sura, int aya) {
    final textController =
        TextEditingController(text: Prefs.getNote(sura, aya));
    return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
            width: 360,
            height: 360,
            clipBehavior: Clip.none,
            padding: EdgeInsets.only(top: 44, right: 16, left: 16),
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
                Positioned(
                    child: TextFormField(
                  autofocus: true,
                  controller: textController,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'note_hint'.l(),
                  ),
                  minLines: 1, //Normal textInputField will be displayed
                  maxLines: 6, //Normal textInputField will be displayed
                )),
                Positioned(
                  bottom: 14,
                  child: TextButton(
                    child: Text("save_l".l()),
                    onPressed: () {
                      Prefs.addNote(sura, aya, textController.text);
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            )));
  }
}
