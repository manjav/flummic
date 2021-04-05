import 'dart:convert';
import 'utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/loader.dart';

class Prefs {
  static SharedPreferences instance;

  static String get locale => instance.getString("locale");
  static set locale(String v) => instance.setString("locale", v);

  static Map<PType, List<String>> persons = Map();

  static void init(Function onInit) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      instance = prefs;

      var initialized = instance.containsKey("locale");
      if (initialized) {
        persons[PType.text] =
            instance.getStringList(PType.text.toString()) ?? null;
        persons[PType.sound] =
            instance.getStringList(PType.sound.toString()) ?? null;
        onInit();
        return;
      }

      var _locale = Utils.getLocaleByTimezone(Utils.findTimezone());
      persons[PType.text] = ["ar.uthmanimin"];
      persons[PType.sound] = <String>[];
      switch (_locale) {
        case "en":
          persons[PType.text].add("en.sahih");
          persons[PType.sound].add("abu_bakr_ash_shaatree");
          persons[PType.sound].add("ibrahim_walk");
          break;
        case "fa":
          persons[PType.text].add("fa.fooladvand");
          persons[PType.sound].add("shahriar_parhizgar");
          persons[PType.sound].add("mahdi_fooladvand");
          break;
        default:
          persons[PType.sound].add("abu_bakr_ash_shaatree");
          break;
      }
      locale = _locale;
      instance.setInt("themeMode", 0);
      instance.setStringList(PType.text.toString(), persons[PType.text]);
      instance.setStringList(PType.sound.toString(), persons[PType.sound]);

      onInit();
    });
  }

  static void addPerson(PType type, String path) {
    if (persons[type].indexOf(path) > -1) return;
    persons[type].add(path);
    instance.setStringList(type.toString(), persons[type]);
  }

  static void removePerson(PType type, String path) {
    if (persons[type].indexOf(path) < 0) return;
    persons[type].remove(path);
    instance.setStringList(type.toString(), persons[type]);
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
      for (var t in map["texts"]) texts[t["path"]] = Person(PType.text, t);
      for (var s in map["sounds"]) sounds[s["path"]] = Person(PType.sound, s);

      for (var t in Prefs.persons[PType.text])
        texts[t]?.select(finalize, null, print);
      for (var s in Prefs.persons[PType.sound])
        sounds[s]?.select(finalize, null, print);
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
      for (var i = 0; i < instance.metadata.suras.length; i++)
        instance.metadata.suras[i].index = i;
      finalize();
    }, null, (String e) => print("error: $e"));
  }

  void finalize() {
    if (metadata == null) return;
    for (var t in Prefs.persons[PType.text])
      if (texts[t]?.state != PState.selected) return;
    for (var r in Prefs.persons[PType.sound])
      if (sounds[r]?.state != PState.selected) return;
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
  int index, ayas, start, order, rukus, page, type;
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
    Prefs.removePerson(type, path);
  }

  void onSelecFinish(Function onDone) {
    state = PState.selected;
    Prefs.addPerson(type, path);
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

  String getURL(int sura, int aya) {
    debugPrint(
        "$url/${Utils.fillZero(sura + 1)}${Utils.fillZero(aya + 1)}.mp3");
    return "$url/${Utils.fillZero(sura + 1)}${Utils.fillZero(aya + 1)}.mp3";
  }
}
