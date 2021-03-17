import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'loader.dart';

class Prefs {
  static SharedPreferences instance;

  static String get locale => instance.getString("locale");
  static set locale(String v) => instance.setString("locale", v);
  static List<String> get reciters => instance.getStringList("_r");
  static set reciters(List<String> v) => instance.setStringList("_r", v);
  static List<String> get translators => instance.getStringList("_t");
  static set translators(List<String> v) => instance.setStringList("_t", v);

  static void init(Function onInit) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      instance = prefs;
      onInit();
    });
  }

  static String setDefaults(String _locale) {
    locale = _locale;
    if (instance.containsKey("_r")) return _locale;

    var _reciters = <String>[];
    var _translators = <String>[];
    switch (_locale) {
      case "en":
        _translators.add("en.sahih");
        _reciters.add("abu_bakr_ash_shaatree");
        _reciters.add("ibrahim_walk");
        break;
      case "fa":
        _translators.add("fa.fooladvand");
        _reciters.add("shahriar_parhizgar");
        _reciters.add("mahdi_fooladvand");
        break;
      default:
        _reciters.add("abu_bakr_ash_shaatree");
        break;
    }
    reciters = _reciters;
    translators = _translators;
    return _locale;
  }
}

class Configs {
  static Configs instance;
  Function onCreate;
  QuranMeta metadata;
  var reciters = Map<String, Person>();
  var translators = Map<String, Person>();

  static String baseURL = "https://grantech.ir/islam/";
  get quran =>
      instance.translators.length > 0 ? instance.translators[0].data : null;

  static void create(Function onCreate) async {
    instance.onCreate = onCreate;
    instance = Configs();
    instance.loadConfigs();
    instance.loadMetadata();
  }

  Future<void> loadConfigs() async {
    await Loader().load("configs.json", baseURL + "configs.ijson",
        (String data) {
      var map = json.decode(data);
      for (var t in map["translators"])
        translators[t["path"]] = Person(t, true);
      for (var r in map["reciters"]) reciters[r["path"]] = Person(r, false);
      translators[0].load(finalize, null, (String e) => print(e));
    }, null, (String e) => print("error: $e"));
  }

  void loadMetadata() async {
    await Loader().load("uthmani-meta.json", baseURL + "uthmani-meta.ijson",
        (String data) {
      var map = json.decode(data);
      instance.metadata = QuranMeta();
      var keys = map.keys;
      for (var k in keys) {
        if (k == "suras")
          for (var c in map[k]) instance.metadata.suras.add(Sura(c));
        else if (k == "juzes")
          for (var c in map[k]) instance.metadata.juzes.add(Juz(c));
        else if (k == "hizbs")
          for (var c in map[k]) instance.metadata.hizbs.add(Part(c));
        else if (k == "pages")
          for (var c in map[k]) instance.metadata.pages.add(Part(c));
      }
      finalize();
    }, null, (String e) => print("error: $e"));
  }

  static void finalize() {
    if (instance.quran == null || instance.metadata == null) return;
    _onCreate();
  }
  }

class QuranMeta {
  List<Sura> suras = <Sura>[];
  List<Juz> juzes = <Juz>[];
  List<Part> hizbs = <Part>[];
  List<Part> pages = <Part>[];
}

class Sura {
  int ayas, start, order, rukus, page, type;
  String name, tname, ename;
  Sura(s) {
    ayas = s["ayas"];
    start = s["start"];
    order = s["order"];
    rukus = s["rukus"];
    page = s["page"];
    name = s["name"];
    tname = s["tname"];
    ename = s["ename"];
    type = s["type"];
  }
}

class Juz extends Part {
  int page;
  String name;
  Juz(j) : super(j) {
    page = j["page"];
    name = j["name"];
  }
}

class Part {
  int sura, aya;
  Part(p) {
    sura = p["sura"];
    aya = p["aya"];
  }
}

class Person {
  int size;
  bool isTranslator, isSelected;
  List<List<String>> data;
  String url, path, name, ename, flag, mode;

  Person(p, bool isTranslator) {
    this.isTranslator = isTranslator;
    url = p["url"];
    path = p["path"];
    name = p["name"];
    ename = p["ename"];
    flag = p["flag"];
    mode = p["mode"];
    size = p["size"];
  }

  void selection(bool value, Function onDone) {
    if (isTranslator && isSelected)
      load(() => onSelecFinish(null), null, (String e) => onSelecFinish(e));
    else
      isSelected = value;
  }

  void onSelecFinish(String log) {
    if (log != null) print(log);
    isSelected = true;
  }

  void load(
      Function onDone, Function(double) onProgress, Function(String) onError) {
    Loader().load(path, url, (String _data) {
      var map = json.decode(_data);
      data = <List<String>>[];
      for (var s in map) {
        var sura = <String>[];
        for (var a in s) sura.add(a);
        data.add(sura);
      }
      onDone();
    }, onProgress, onError);
  }
}
