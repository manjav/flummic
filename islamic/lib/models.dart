import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'loader.dart';

class Prefs {
  static SharedPreferences instance;

  static String get locale => instance.getString("locale");
  static set locale(String v) => instance.setString("locale", v);

  static List<String> _sounds;
  static List<String> _texts;

  static void init(Function onInit) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      instance = prefs;
      Prefs.instance.clear();
      _sounds = instance.getStringList("_s") ?? null;
      _texts = instance.getStringList("_t") ?? null;
      onInit();
    });
  }

  static String setDefaults(String _locale) {
    locale = _locale;
    _sounds = <String>[];
    _texts = ["ar.uthmanimin"];
    switch (_locale) {
      case "en":
        _texts.add("en.sahih");
        _sounds.add("abu_bakr_ash_shaatree");
        _sounds.add("ibrahim_walk");
        break;
      case "fa":
        _texts.add("fa.fooladvand");
        _sounds.add("shahriar_parhizgar");
        _sounds.add("mahdi_fooladvand");
        break;
      default:
        _sounds.add("abu_bakr_ash_shaatree");
        break;
    }
    instance.setStringList("_t", _texts);
    instance.setStringList("_s", _sounds);
    return _locale;
  }

  static List define(PType type) {
    if (type == PType.text) return ["_t", _texts];
    return ["_s", _sounds];
  }

  static void add(PType type, String path) {
    var def = define(type);
    if (def[1].indexOf(path) > -1) return;
    def[1].add(path);
    instance.setStringList(def[0], def[1]);
  }

  static void remove(PType type, String path) {
    var def = define(type);
    if (def[1].indexOf(path) < 0) return;
    def[1].remove(path);
    instance.setStringList(def[0], def[1]);
  }

  static void update(PType type, List<String> value) {
    var def = define(type);
    def[1] = value;
    instance.setStringList(def[0], def[1]);
  }
}

class Configs {
  static Configs instance;
  Function onCreate;
  QuranMeta metadata;
  var sounds = Map<String, Person>();
  var texts = Map<String, Person>();

  static String baseURL = "https://grantech.ir/islam/";
  get quran => instance.texts["ar.uthmanimin"]?.data;

  static void create(Function onCreate) async {
    instance = Configs();
    instance.onCreate = onCreate;
    instance.loadConfigs();
    instance.loadMetadata();
  }

  Future<void> loadConfigs() async {
    await Loader().load("configs.json", baseURL + "configs.ijson",
        (String data) {
      var map = json.decode(data);
      for (var t in map["texts"]) texts[t["path"]] = Person(t, true);
      for (var r in map["sounds"]) sounds[r["path"]] = Person(r, false);

      for (var t in Prefs.texts) texts[t]?.select(finalize, null, print);
      for (var r in Prefs.sounds) sounds[r]?.select(finalize, null, print);
    }, null, print);
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

  void finalize() {
    if (quran == null || metadata == null) return;
    for (var t in Prefs.texts) if (texts[t]?.state != PState.selected) return;
    for (var r in Prefs.sounds) if (sounds[r]?.state != PState.selected) return;
    onCreate();
  }
}

class QuranMeta {
  List<Juz> juzes = <Juz>[];
  List<Sura> suras = <Sura>[];
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

enum PState { waiting, downloading, ready, selected }
enum PType { text, sound, athan }

class Person {
  int size;
  PType type;
  PState state;
  List<List<String>> data;
  double progress = 0;
  String url, path, name, ename, flag, mode;
  Loader loader;

  Person(this.type, p) {
    state = type == PType.text ? PState.waiting : PState.ready;
    url = p["url"];
    path = p["path"];
    name = p["name"];
    ename = p["ename"];
    flag = p["flag"];
    mode = p["mode"];
    size = p["size"];
  }

  void select(
      Function onDone, Function(double) onProgress, Function(String) onError) {
    print("select $path");
    if (state == PState.waiting)
      load(() => onSelecFinish(onDone), onProgress, onError);
    else
      onSelecFinish(onDone);
  }

  void deselect() {
    state = PState.ready;
    Prefs.remove(type, path);
  }

  void onSelecFinish(Function onDone) {
    state = PState.selected;
    Prefs.add(type, path);
    onDone();
  }

  void load(
      Function onDone, Function(double) onProgress, Function(String) onError) {
    state = PState.downloading;
    loader = Loader();
    loader.load(path, url, (String _data) {
      var map = json.decode(_data);
      print(path);
      data = <List<String>>[];
      for (var s in map) {
        var sura = <String>[];
        for (var a in s) sura.add(a);
        data.add(sura);
      }
      if (onDone != null) onDone();
    }, (double p) {
      progress = p;
      if (onProgress != null) onProgress(p);
    }, (String e) {
      state = PState.waiting;
      if (onError != null) onError(e);
    });
  }

  void cancelLoading() {
    if (state != PState.downloading) return;
    loader.abort();
    state = PState.waiting;
  }
}
