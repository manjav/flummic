import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'main.dart';

extension Localization on String {
  static Map<String, String> sentences;
  static Future<void> change(BuildContext context, String lang) async {
    String data;
    debugPrint('Load $lang.json');
    try {
      data = await rootBundle.loadString('locs/$lang.json');
    } catch (_) {
      data = await rootBundle.loadString('locs/${Platform.localeName}.json');
    }
    MyApp.of(context).setLocale(lang);

    var _result = json.decode(data);
    sentences = Map();
    _result.forEach((String key, dynamic value) {
      sentences[key] = value.toString();
    });
  }

  String l([List<String> args]) {
    final key = this;
    if (sentences == null) {
      throw "[Localization System] sentences = null";
    }
    String res = sentences[key];
    if (res == null) {
      res = key;
    } else {
      if (args != null) {
        args.forEach((arg) {
          res = res.replaceFirst(RegExp(r'%s'), arg.toString());
        });
      }
    }
    return res;
  }

  static void fromJson(Map<String, dynamic> json) => sentences = json;

  Map<String, String> toJson() => sentences;
}

extension LocalizeNums on int {
  String toArabic() {
    return this.toString()
        .replaceAll('0', '٠')
        .replaceAll('1', '١')
        .replaceAll('2', '٢')
        .replaceAll('3', '٣')
        .replaceAll('4', '٤')
        .replaceAll('5', '٥')
        .replaceAll('6', '٦')
        .replaceAll('7', '٧')
        .replaceAll('8', '٨')
        .replaceAll('9', '٩');
  }

  String toPersian() {
    return this.toString()
        .replaceAll('0', '٠')
        .replaceAll('1', '١')
        .replaceAll('2', '٢')
        .replaceAll('3', '٣')
        .replaceAll('4', '۴')
        .replaceAll('5', '۵')
        .replaceAll('6', '۶')
        .replaceAll('7', '٧')
        .replaceAll('8', '٨')
        .replaceAll('9', '٩');
  }

  String n([String languageString]) {
    if (Bidi.isRtlLanguage(languageString)) return this.toArabic();
    return this.toString();
  }
}
