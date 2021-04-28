import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:islamic/utils/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/loader.dart';
import 'utils/utils.dart';

class Prefs {
  static late SharedPreferences instance;
  static Map<PType, List<String>> persons = Map();
  static late Map<String, String> notes = Map();

  static String get locale => instance.getString("locale") ?? "en";
  static String get naviMode => instance.getString("naviMode") ?? "sura";
  static double get textScale => instance.getDouble("textScale") ?? 1;
  static int get themeMode => instance.getInt("themeMode") ?? 0;
  static int get numRuns => instance.getInt("numRuns") ?? 0;
  static int get rate => instance.getInt("rate") ?? 3;

  static int get selectedSura => instance.getInt("s") ?? 0;
  static set selectedSura(int s) => instance.setInt("s", s);
  static int get selectedAya => instance.getInt("a") ?? 0;
  static set selectedAya(int a) => instance.setInt("a", a);

  static void init(Function onInit) {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      instance = prefs;

      bool initialized = instance.containsKey("locale");
      if (initialized) {
        persons[PType.text] =
            instance.getStringList(PType.text.toString()) ?? [];
        persons[PType.sound] =
            instance.getStringList(PType.sound.toString()) ?? [];
        Map<String, dynamic> map =
            jsonDecode(instance.getString("bookmarks") ?? "{}");
        notes = map.cast();
        instance.setInt("numRuns", numRuns + 1);
        onInit();
        return;
      }

      var _locale = Utils.getLocaleByTimezone(Utils.findTimezone());
      List<String> texts = ["ar.uthmanimin"];
      List<String> sounds = <String>[];
      switch (_locale) {
        case "en":
          texts.add("en.sahih");
          sounds.add("mishary_rashid_alafasy");
          sounds.add("ibrahim_walk");
          break;
        case "fa":
          texts.add("fa.fooladvand");
          sounds.add("shahriar_parhizgar");
          sounds.add("mahdi_fooladvand");
          break;
        default:
          sounds.add("abu_bakr_ash_shaatree");
          break;
      }
      instance.setInt("numRuns", 0);
      instance.setInt("themeMode", 0);
      instance.setString("naviMode", "sura");
      instance.setString("locale", _locale);
      instance.setString("bookmarks", "{}");
      instance.setStringList(
          PType.text.toString(), persons[PType.text] = texts);
      instance.setStringList(
          PType.sound.toString(), persons[PType.sound] = sounds);

      onInit();
    });
  }

  static void addPerson(PType type, String path) {
    if (persons[type]!.indexOf(path) > -1) return;
    persons[type]!.add(path);
    instance.setStringList(type.toString(), persons[type]!);
  }

  static void removePerson(PType type, String path) {
    if (persons[type]!.indexOf(path) < 0) return;
    persons[type]!.remove(path);
    instance.setStringList(type.toString(), persons[type]!);
  }

  static void addNote(int sura, int aya, String note) {
    notes["${Utils.fillZero(sura)}${Utils.fillZero(aya)}"] = note;
    instance.setString("bookmarks", jsonEncode(notes));
  }

  static void removeNote(int sura, int aya) {
    notes.remove("${Utils.fillZero(sura)}${Utils.fillZero(aya)}");
    instance.setString("bookmarks", jsonEncode(notes));
  }

  static String? getNote(int sura, int aya) {
    return notes["${Utils.fillZero(sura)}${Utils.fillZero(aya)}"];
  }

  static bool? hasNote(int sura, int aya) {
    return notes.containsKey("${Utils.fillZero(sura)}${Utils.fillZero(aya)}");
  }
}

class Configs {
  static late Configs instance;
  late Function onCreate;
  late Function(dynamic) onError;
  QuranMeta? _metadata;
  QuranMeta get metadata => _metadata ?? QuranMeta();

  late List<Word> words;
  List<List<String>>? simpleQuran;
  Map<String, List<List<Aya>>> navigations = Map();

  var sounds = Map<String, Person>();
  var texts = Map<String, Person>();

  static String baseURL = "https://grantech.ir/islam/";
  get quran => instance.texts["ar.uthmanimin"]?.data;

  static void create(Function onCreate, Function(dynamic) onError) async {
    instance = Configs();
    if (Prefs.locale != "fa") baseURL = "https://hidaya.sarand.net/";
    instance.onCreate = onCreate;
    instance.onError = onError;
    instance.loadConfigs();
    instance.loadMetadata();
  }

  Future<void> loadConfigs() async {
    await Loader().load("config.json", baseURL + "config.ijson", (String data) {
      var map = json.decode(data);
      for (var t in map["texts"]) texts[t["path"]] = Person(PType.text, t);
      for (var s in map["sounds"]) sounds[s["path"]] = Person(PType.sound, s);

      for (var t in Prefs.persons[PType.text]!) texts[t]?.select(finalize);
      for (var s in Prefs.persons[PType.sound]!) sounds[s]?.select(finalize);
    });
  }

  void loadMetadata() async {
    await Loader().load("uthmani-meta.json", baseURL + "uthmani-meta.ijson",
        (String data) {
      var map = json.decode(data);
      var _m = QuranMeta();
      var keys = map.keys;
      for (var k in keys) {
        if (k == "suras")
          for (var c in map[k]) _m.suras.add(Sura(c));
        else if (k == "juzes")
          for (var c in map[k])
            _m.juzes.add(Juz(c['sura'], c['aya'], c['page'], c['name']));
        else if (k == "hizbs")
          for (var c in map[k]) _m.hizbs.add(Part(c['sura'], c['aya']));
        else if (k == "pages")
          for (var c in map[k]) _m.pages.add(Part(c['sura'], c['aya']));
      }
      for (var i = 0; i < _m.suras.length; i++) _m.suras[i].index = i;
      _metadata = _m;
      createAyas();
      finalize();
    }, null, onError);
  }

  void finalize() {
    if (_metadata == null) return;
    for (var t in Prefs.persons[PType.text]!)
      if (texts[t]?.state != PState.selected) return;
    for (var r in Prefs.persons[PType.sound]!)
      if (sounds[r]?.state != PState.selected) return;
    onCreate();
  }

  Future<void> loadSearchAssets(Function onDone) async {
    if (simpleQuran != null) {
      onDone();
      return;
    }
    await Loader().load("words.json", baseURL + "words.zip",
        (String data) async {
      var list = json.decode(data);
      words = <Word>[];
      for (var w in list) words.add(new Word(w));
      await Loader().load("simple.json", baseURL + "simple.zip", (String data) {
        var list = json.decode(data);
        simpleQuran = <List<String>>[];
        for (var s in list) {
          var sura = <String>[];
          for (var a in s) sura.add(a);
          simpleQuran!.add(sura);
        }
        onDone();
      });
    });
  }

  List<List<Aya>> get pageItems => navigations[Prefs.naviMode]!;
  void createAyas() {
    var t = DateTime.now().millisecondsSinceEpoch;
    Aya aya;
    navigations["all"] = <List<Aya>>[];
    navigations["all"]!.add(<Aya>[]);
    navigations["sura"] = <List<Aya>>[];
    for (var i = 0, n = 0; i < 114; i++) {
      navigations["sura"]!.add(<Aya>[]);
      for (var j = 0; j < _metadata!.suras[i].ayas; j++, n++) {
        aya = Aya(i, j, n);
        navigations["all"]![0].add(aya);
        navigations["sura"]![i].add(aya);
      }
    }
    fillParts("juze", _metadata!.juzes);
    fillParts("page", _metadata!.pages);
    print(DateTime.now().millisecondsSinceEpoch - t);
  }

  void fillParts(String mode, List<Part> source) {
    var part = <List<Aya>>[];
    for (var i = 0; i < source.length; i++) {
      part.add(<Aya>[]);
      var p = source[i];
      var np = i > source.length - 2 ? Part(115, 1) : source[i + 1];
      var a = p.aya - 1;
      var index = 0;
      for (var s = p.sura - 1; s < np.sura; s++, a = 0) {
        var len = s == np.sura - 1 ? np.aya - 1 : _metadata!.suras[s].ayas;
        for (; a < len; a++) {
          var aya = navigations["sura"]![s][a];
          if (mode == "juze") {
            aya.juze = i;
            aya.juzeIndex = index;
          } else {
            aya.page = i;
            aya.pageIndex = index;
          }
          part[i].add(aya);
          index++;
        }
      }
    }
    navigations[mode] = part;
  }

  List<int> getPart(int sura, int aya) {
    if (Prefs.naviMode == "sura") return [sura, aya];
    var a = navigations["sura"]![sura][aya];
    if (Prefs.naviMode == "juze") return [a.juze, a.juzeIndex];
    return [a.page, a.pageIndex];
  }
}

class QuranMeta {
  List<Juz> juzes = <Juz>[];
  List<Sura> suras = <Sura>[];
  List<Part> hizbs = <Part>[];
  List<Part> pages = <Part>[];
}

class Sura {
  late int index, ayas, start, order, rukus, page, type;
  late String name, tname, ename;
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

  String get title => Localization.isRTL ? name : tname;
}

class Juz extends Part {
  int page;
  String name;
  Juz(int sura, int aya, this.page, this.name) : super(sura, aya);
}

class Aya extends Search {
  late int page, juze, pageIndex, juzeIndex;
  Aya(int sura, int aya, int index) : super(sura, aya, index);
  Map<String, dynamic> toJson() => {'sura': sura, 'aya': aya};
}

class Part {
  int sura, aya;
  Part(this.sura, this.aya);
}

class Word {
  late int c;
  late String t;
  Word(w) {
    t = w["t"];
    c = w["c"];
  }
}

class Search {
  int sura;
  int aya;
  int index;
  Search(this.sura, this.aya, this.index);
}

enum PState { waiting, downloading, ready, selected }
enum PType { text, sound, athan }

class Person {
  int? size;
  PType type;
  late PState state;
  late Loader loader;
  double progress = 0;
  late List<List<String>> data;
  late String url, path, name, ename, flag, mode;

  Person(this.type, p) {
    state = type == PType.text ? PState.waiting : PState.ready;
    name = p["name"];
    ename = p["ename"] ?? p["name"];
    url = p["url"] ?? '${Configs.baseURL}contents/${p["path"]}.json.zip';
    path = p["path"];
    flag = p["flag"];
    mode = p["mode"];
    size = p["size"];
  }

  void select(Function onDone,
      [Function(double)? onProgress, Function(dynamic)? onError]) {
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

  void load(Function onDone, Function(double)? onProgress,
      Function(dynamic)? onError) {
    state = PState.downloading;
    loader = Loader();
    loader.load(path, url, (String _data) {
      var list = json.decode(_data);
      data = <List<String>>[];
      for (var s in list) {
        var sura = <String>[];
        for (var a in s) sura.add(a);
        data.add(sura);
      }
      onDone();
    }, (double p) {
      progress = p;
      if (onProgress != null) onProgress(p);
    }, (e) {
      state = PState.waiting;
      onError?.call(e);
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

  String get title => Localization.isRTL ? name : ename;

  Map<String, dynamic> toJson() {
    return {
      "path": path,
      "ename": ename,
      "name": name,
      "url": url,
      "mode": mode
    };
  }
}
