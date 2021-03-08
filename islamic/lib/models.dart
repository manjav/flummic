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

  List<Person> reciters;
  List<Person> translators;

  static void onLoadData(String data) {
    instance = Configs();
    var map = json.decode(data);
    instance.translators = <Person>[];
    for (var p in map["translators"]) instance.translators.add(Person(p));
    instance.reciters = <Person>[];
    for (var p in map["reciters"]) instance.reciters.add(Person(p));
    _onCreate();
  }
}

class Person {
  String url;
  String path;
  String name;
  String ename;
  String flag;
  String mode;
  int size;

  Person(p) {
    url = p["url"];
    path = p["path"];
    name = p["name"];
    ename = p["ename"];
    flag = p["flag"];
    mode = p["mode"];
    size = p["size"];
  }
}
