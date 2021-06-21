import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models.dart';

class Texts {
  static final patterns = [
    ' ۛ',
    ' ۚ',
    ' ۖ',
    ' ۗ',
    ' ۙ',
    ' ۘ',
    ' ۛۛ',
    // 'َ',
    // '۞',
    // '﴾',
    // '﴿',
    // '٠',
    // '١',
    // '٢',
    // '٣',
    // '٤',
    // '٥',
    // '٦',
    // '٧',
    // '٨',
    // '٩'
  ];
  static TextStyle red = TextStyle(color: Colors.red[400]);
  static TextStyle teal = TextStyle(color: Colors.teal[300]);
  static RichText quran(String hizb, String text, String end, mainStyle) {
    final spans = <TextSpan>[];
    if (hizb.length > 0) spans.add(TextSpan(text: hizb, style: teal));
    spans.addAll(_getSpans(text, red));
    if (end.length > 0) spans.add(TextSpan(text: end, style: teal));
    return RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        text: new TextSpan(style: mainStyle, children: spans));
  }

  static List<TextSpan> _getSpans(String text, TextStyle style) {
    List<TextSpan> spans = [];
    int spanBoundary = 0;

    do {
      bool found = false;
      for (int i = 0; i < patterns.length; i++) {
        // look for the next match
        var startIndex = text.indexOf(patterns[i], spanBoundary);
        if (startIndex > -1) {
          found = true;
          // add any unstyled text before the next match
          if (startIndex > spanBoundary)
            spans.add(TextSpan(text: text.substring(spanBoundary, startIndex)));

          // style the matched text
          final endIndex = startIndex + 1;
          // final spanText = text.substring(startIndex, endIndex + 1);
          spans.add(TextSpan(text: "${patterns[i]}", style: style));

          // mark the boundary to start the next search from
          spanBoundary = endIndex;
        }
      }
      // if no more matches then add the rest of the string without style
      if (!found) {
        spans.add(TextSpan(text: text.substring(spanBoundary)));
        return spans;
      }
      // continue until there are no more matches
    } while (spanBoundary < text.length);

    return spans;
  }

  static String getHizbFlag(int sura, int aya, int index) {
    if (index > 0) return "";
    var hizbs = Configs.instance.metadata.hizbs;
    var len = hizbs.length;
    for (var i = 0; i < len; i++) {
      if (hizbs[i].sura > sura) return "";
      if (hizbs[i].sura == sura && hizbs[i].aya == aya) return "۞ ";
    }
    return "";
  }
}
