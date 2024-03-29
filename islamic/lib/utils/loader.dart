import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:crypto/crypto.dart';

class Loader {
  HttpClient httpClient = HttpClient();
  Future<Loader> load(String path, String url, Function(String) onDone,
      {Function(double)? onProgress,
      Function(dynamic)? onError,
      String? hash,
      bool forceUpdate = false}) async {
    var dir = (await getApplicationSupportDirectory()).path;
    var ext = p.extension(url);
    var file = File('$dir/$path');
    var exists = await file.exists();
    if (exists) {
      var bytes = await file.readAsBytes();
      if (hashMatch(bytes, hash, path)) {
        debugPrint("==> Complete loading $path");
        onDone(utf8.decode(bytes));
        if (!forceUpdate) return this;
      }
    }

    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode != 200) print('Failure status code 😱');
      var contentLength = response.contentLength;
      var bytes = <int>[];
      response.asBroadcastStream().listen((List<int> newBytes) {
        bytes.addAll(newBytes);
        onProgress?.call(bytes.length / contentLength);
      }, onDone: () async {
        if (!hashMatch(bytes, hash, url))
          return onError?.call("$path md5 is invalid!");
        if (ext == ".zip" || ext == ".zson") {
          Archive archive = ZipDecoder().decodeBytes(bytes);
          bytes = archive.first.content as List<int>;
        }
        await file.writeAsBytes(bytes);
        debugPrint("==> Complete loading $url");
        if (!exists || !forceUpdate) onDone(utf8.decode(bytes));
      }, onError: (d) {
        print("$url loading failed.");
        return onError?.call(d);
      }, cancelOnError: true);
      // } on SocketException {
      //   print('No Internet connection 😑');
      // } on HttpException {
      //   print("Couldn't find the post 😱");
      // } on FormatException {
      //   print("Bad response format 👎");
    } on Exception {
      print("Exception while $url loading.");
      onError?.call("exception");
    }
    return this;
  }

  void abort() => httpClient.close(force: true);

  bool hashMatch(List<int> bytes, String? hash, String path) {
    if (hash == null) return true;
    var _hash = md5.convert(bytes);
    debugPrint("$path MD5 $hash <> $_hash}");
    return hash == _hash.toString();
  }
}
