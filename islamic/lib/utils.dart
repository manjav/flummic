import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class Utils {

  static String findTimezone() {
    tz.initializeTimeZones();
    var locations = tz.timeZoneDatabase.locations.values;
    var tzo = DateTime.now().timeZoneOffset.inMilliseconds;
    for (var l in locations) if (l.currentTimeZone.offset == tzo) return l.name;
    return "Europe/London";
  }
}
