import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'models.dart';

class Utils {
  static Function(String p1) onGetLocaleFinish;

  static void getLocale(Function(String) onFinish) {
    SharedPreferences.getInstance().then(onPrefsInit);
    onGetLocaleFinish = onFinish;
  }

  static void onPrefsInit(SharedPreferences prefs) {
    Prefs.prefs = prefs;
    String locale = "en";
    if (prefs.containsKey('locale')) {
      locale = prefs.getString('locale');
      onGetLocaleFinish(locale);
      return;
    }
    locale = getLocaleByTimezone(findTimezone());
    prefs.setString('locale', locale);
    onGetLocaleFinish(locale);
  }

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
}
