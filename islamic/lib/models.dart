import 'dart:convert';

import 'loader.dart';

class Configs {
  static Configs instance;

  static Function _onCreate;
  static void create(Function onCreate) async {
    _onCreate = onCreate;
    var url = "https://grantech.ir/islam/configs.ijson";
    await Loader().load("configs.json", url, onLoadData, null,
        (String error) => print("error: $error"));
  }

  get quran => instance.translators[0].data;
  List<Person> reciters;
  List<Person> translators;

  static void onLoadData(String data) {
    instance = Configs();
    var map = json.decode(data);
    instance.translators = <Person>[];
    for (var p in map["translators"]) instance.translators.add(Person(p));
    instance.reciters = <Person>[];
    for (var p in map["reciters"]) instance.reciters.add(Person(p));
    
    instance.translators[0].load(_onCreate, null, null);
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
