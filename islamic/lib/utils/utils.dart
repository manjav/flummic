import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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

   static bool equalLists(List left, List right) {
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
}
