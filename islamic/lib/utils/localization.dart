import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:islamic/models.dart';

import '../main.dart';
import 'loader.dart';

extension Localization on String {
  static bool isRTL = false;
  static String languageCode = "en";
  static Map<String, dynamic>? _sentences;
  static TextDirection dir = TextDirection.ltr;

  static void change(String _languageCode, {Function(Locale)? onDone}) {
    dynamic? _result;
    var _loc = MyApp.supportedLocales.firstWhere(
        (l) => l.languageCode == _languageCode,
        orElse: () => MyApp.supportedLocales[2]);
    languageCode = _loc.languageCode;
    isRTL = Bidi.isRtlLanguage(languageCode);
    dir = isRTL ? TextDirection.rtl : TextDirection.ltr;
    List<dynamic> files = Configs.instance.configs["files"];
    var file = files.firstWhere((f) => f["path"] == languageCode);
    Loader().load(
        "$languageCode.json", "${Configs.baseURL}/locales/$languageCode.ijson",
        (String data) {
      _result = json.decode(data);
      _sentences = Map();
      _result.forEach((String key, dynamic value) {
        _sentences![key] = value.toString();
      });
      onDone?.call(_loc);
    }, hash: file != null ? file["md5"] : null);
  }

  String l([List<String>? args]) {
    final key = this;
    if (_sentences == null) throw "[Localization System] sentences = null";
    String? res = _sentences![key];
    if (res == null) {
      res = key;
    } else {
      if (args != null) {
        args.forEach((arg) {
          res = res!.replaceFirst(RegExp(r'%s'), arg.toString());
        });
      }
    }
    return res!;
  }

  String toArabic() {
    return this
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
    return this
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

  String n([String? languageString]) {
    if (languageString != null) {
      if (Bidi.isRtlLanguage(languageString)) return this.toPersian();
    } else if (isRTL) {
      return this.toPersian();
    }
    return this;
  }

  /*  static String getSimpleString(String str, [String loc = "ar"]) {
    if (loc == "ar") {
      var signs = "َُِّْٰۭٓۢۚۖۗۦًٌٍۙۘۜۥ".split("");
      for (var i = 0; i < signs.length; i++) str = str.replaceAll(signs[i], "");

      var alefs = "إأٱآ".split("");
      for (var i = 0; i < alefs.length; i++)
        str = str.replaceAll(alefs[i], "ا");

      str = str.replaceAll("ة", "ه");
      str = str.replaceAll("ؤ", "و");
      str = str.replaceAll("ي", "ی");
      str = str.replaceAll("ى", "ی");
      str = str.replaceAll("ك", "ک");
      //str = str.replaceAll("ی","ي");
    }
    return str.toLowerCase();
  }

  static String getFullPath(
      String path, int sura, int aya, String post /* ="dat" */) {
    return (path +
        "/" +
        getZeroNum(sura.toString()) +
        "/" +
        getZeroNum(sura.toString()) +
        getZeroNum(aya.toString()) +
        "." +
        post);
  }


   */
}

extension LocalizeInt on int {
  String toArabic() {
    return this.toString().toArabic();
  }

  String toPersian() {
    return this.toString().toPersian();
  }

  String n([String? languageString]) {
    return this.toString().n(languageString);
  }
}

extension LocalizeDouble on double {
  String toArabic() {
    return this.toString().toArabic();
  }

  String toPersian() {
    return this.toString().toPersian();
  }

  String n([String? languageString]) {
    return this.toString().n(languageString);
  }
}
