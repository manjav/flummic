import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islamic/widgets/popup.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wakelock/wakelock.dart';

import 'localization.dart';

class Utils {
  static String getLocaleByTimezone(String timezone) {
    switch (timezone) {
      case "Asia/Tehran":
      case "Asia/Kabul":
      case "Asia/Dushanbe":
        return "fa";

      default:
        return "en";
    }
  }

  static String findTimezone() {
    tz.initializeTimeZones();
    var locations = tz.timeZoneDatabase.locations.values;
    var tzo = DateTime.now().timeZoneOffset.inMilliseconds;
    for (var l in locations) if (l.currentTimeZone.offset == tzo) return l.name;
    return "Europe/London";
  }

  static bool equalLists(List? left, List? right) {
    if (left == null || right == null) return false;
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) if (left[i] != right[i]) return false;
    return true;
  }

  static String fillZero(int number) {
    if (number < 10) return "00$number";
    if (number < 100) return "0$number";
    return "$number";
  }

  static Timer? _wakeupTimer;
  static void wakeup(BuildContext context, {int seconds = 15}) async {
  static void wakeup({int seconds = 60}) async {
    debugPrint("wakeup started");
    _wakeupTimer?.cancel();
    Wakelock.enable();
    _wakeupTimer = Timer(Duration(seconds: seconds), () {
      Generics.confirm(context,
          text: "wake_l".l(),
          onAccept: Wakelock.enable,
          onDecline: Wakelock.disable);
    });
  }
}
