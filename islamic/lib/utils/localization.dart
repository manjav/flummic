import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' show Bidi;

import '../main.dart';

extension Localization on String {
  static bool isRTL = false;
  static String languageCode = "en";
  static Map<String, dynamic>? _sentences;
  static TextDirection dir = TextDirection.ltr;

  static Future<void> change(BuildContext context, String _languageCode) async {
    String data;
    debugPrint('Load $_languageCode.json');
    try {
      data = await rootBundle.loadString('locs/$_languageCode.json');
    } catch (_) {
      data = await rootBundle.loadString('locs/${Platform.localeName}.json');
    }
    languageCode = _languageCode;
    isRTL = Bidi.isRtlLanguage(languageCode);
    dir = isRTL ? TextDirection.rtl : TextDirection.ltr;
    MyApp.of(context)!.setLocale(languageCode);

    var _result = json.decode(data);
    _sentences = Map();
    _result.forEach((String key, dynamic value) {
      _sentences![key] = value.toString();
    });
  }

  String l([List<String>? args]) {
    final key = this;
    if (_sentences == null) {
      throw "[Localization System] sentences = null";
    }
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

  // static void fromJson(Map<String, dynamic> json) => sentences = json;

  // Map<String, String> toJson() => sentences!;

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
