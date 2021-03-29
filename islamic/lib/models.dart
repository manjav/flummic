import 'dart:convert';
import 'package:islamic/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'loader.dart';

class Prefs {
  static SharedPreferences instance;

  static String get locale => instance.getString("locale");
  static set locale(String v) => instance.setString("locale", v);

  static List<String> _sounds;
  static List<String> get sounds => _sounds;
  static set sounds(List<String> v) {
    if (Utils.equalLists(_sounds, v)) return;
    _sounds = v;
    instance.setStringList("_s", v);
  }

  static List<String> _texts;
  static List<String> get texts => _texts;
  static set texts(List<String> v) {
    if (Utils.equalLists(_texts, v)) return;
    _texts = v;
    instance.setStringList("_t", v);
  }

  static void init(Function onInit) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      instance = prefs;
      _sounds = instance.getStringList("_s") ?? null;
      _texts = instance.getStringList("_t") ?? null;
      onInit();
    });
  }

  static String setDefaults(String _locale) {
    locale = _locale;
    var __sounds = <String>[];
    var __texts = ["ar.uthmanimin"];
    switch (_locale) {
      case "en":
        __texts.add("en.sahih");
        __sounds.add("abu_bakr_ash_shaatree");
        __sounds.add("ibrahim_walk");
        break;
      case "fa":
        __texts.add("fa.fooladvand");
        __sounds.add("shahriar_parhizgar");
        __sounds.add("mahdi_fooladvand");
        break;
      default:
        __sounds.add("abu_bakr_ash_shaatree");
        break;
    }
    sounds = __sounds;
    texts = __texts;
    return _locale;
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
    if (state == PState.waiting)
      load(() => onSelecFinish(onDone), onProgress, onError);
    else
      onSelecFinish(onDone);
  }

  void deselect() {
    state = PState.ready;
    Prefs.texts.remove(path);
  }

  void onSelecFinish(Function onDone) {
    state = PState.selected;
    if (isText && Prefs.texts.indexOf(path) == -1)
      Prefs.texts.add(path);
    else if (!isText && Prefs.sounds.indexOf(path) == -1)
      Prefs.sounds.add(path);
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
