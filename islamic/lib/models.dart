import 'dart:convert';
import 'loader.dart';

class Configs {
  static Configs instance;
  List<Person> reciters;
  List<Person> translators;
  QuranMeta metadata;

  static String baseURL = "https://grantech.ir/islam/";
  get quran => instance.translators[0].data;

  static Function _onCreate;
  static void create(Function onCreate) async {
    _onCreate = onCreate;
    instance = Configs();
    loadConfigs();
    loadMetadata();
  }

  static Future<void> loadConfigs() async {
    await Loader().load("configs.json", baseURL + "configs.ijson",
        (String data) {
      var map = json.decode(data);
      instance.translators = <Person>[];
      for (var p in map["translators"]) instance.translators.add(Person(p));
      instance.reciters = <Person>[];
      for (var p in map["reciters"]) instance.reciters.add(Person(p));
      instance.translators[0].load(finalize, null, (String e) => print("error: $e"));
    }, null, (String e) => print("error: $e"));
  }

  static void loadMetadata() async {
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
    if (instance.translators[0].data == null || instance.metadata == null)
      return;
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
  List<List<String>> data;
  String url, path, name, ename, flag, mode;
  Person(p) {
    url = p["url"];
    path = p["path"];
    name = p["name"];
    ename = p["ename"];
    flag = p["flag"];
    mode = p["mode"];
    size = p["size"];
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
