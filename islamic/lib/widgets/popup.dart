import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islamic/models.dart';
import 'package:islamic/utils/localization.dart';

import '../main.dart';

class AyaDetails extends StatefulWidget {
  final int sura, aya;

  AyaDetails(this.sura, this.aya);

  @override
  State<StatefulWidget> createState() => AyaDetailsState();
}

class AyaDetailsState extends State<AyaDetails> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
        height: 160,
        child: Stack(alignment: Alignment.topCenter,
            // fit: StackFit.expand,
            // clipBehavior: Clip.none,
            children: [
              Positioned(
                  top: 12,
                  width: 32,
                  height: 4,
                  child: Container(
                    decoration: BoxDecoration(
                        color: theme.appBarTheme.iconTheme.color,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                  )),
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
                        getButton(Icons.bookmark_border, "bookmark", theme),
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

      case "bookmark":
        break;

      default:
        MyApp.of(context).player.select(widget.sura, widget.aya, 0, true);
        break;
    }
    Navigator.of(context).pop();
  }
}
