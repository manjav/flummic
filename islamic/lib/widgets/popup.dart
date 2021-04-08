import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islamic/models.dart';
import 'package:islamic/utils/localization.dart';
import 'package:share/share.dart';

import '../main.dart';

class AyaDetails extends StatefulWidget {
  final int sura, aya;

  AyaDetails(this.sura, this.aya);

  @override
  State<StatefulWidget> createState() => AyaDetailsState();
}

class AyaDetailsState extends State<AyaDetails> {
  String bookmark;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bookmark = Prefs.getBookmark(widget.sura, widget.aya);
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
                  "${'sura_l'.l()} ${Configs.instance.metadata.suras[widget.sura].name} - ${'verse_l'.l()} ${(widget.aya + 1).toArabic()}",
                  style: theme.textTheme.headline5,
                ),
              ),
              Positioned(
                  right: 4,
                  bottom: 4,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        getButton(Icons.play_circle_fill, "play", theme),
                        getButton(getBookmarkIcon(), "bookmark", theme),
                        getButton(Icons.share, "share", theme)
                      ]))
            ]));
  }

  IconButton getButton(IconData icon, String type, theme) {
    return IconButton(
        padding: EdgeInsets.all(28),
        icon: Icon(icon, color: theme.appBarTheme.iconTheme.color),
        onPressed: () => onPressed(type));
  }

  void onPressed(String type) {
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

      case "bookmark":
        setState(() {
          bookmark == null
              ? Prefs.addBookmark(s, a, "")
              : Prefs.removeBookmark(s, a);
        });
        break;

      default:
        MyApp.of(context).player.select(widget.sura, widget.aya, 0, true);
        Navigator.of(context).pop();
        break;
    }
  }

  IconData getBookmarkIcon() {
    if (bookmark == null)
      return Icons.bookmark_border;
    else if (bookmark == "")
      return Icons.bookmark;
    else
      return Icons.bookmark;
  }
}

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
        top: 12,
        width: 32,
        height: 4,
        child: Container(
          decoration: BoxDecoration(
              color: theme.appBarTheme.iconTheme.color,
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
}
