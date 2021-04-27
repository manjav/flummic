import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class Loader {
  HttpClient httpClient = HttpClient();
  Future<Loader> load(String path, String url, Function(String) onDone,
      [Function(double)? onProgress, Function(dynamic)? onError]) async {
    var baseURL = (await getApplicationSupportDirectory()).path;
    var ext = p.extension(url);
    var file = File('$baseURL/$path');
    if (await file.exists()) {
      var str = await file.readAsString();
      onDone(str);
      return this;
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
        if (ext == ".zip" || ext == ".zson") {
          Archive archive = ZipDecoder().decodeBytes(bytes);
          bytes = archive.first.content as List<int>;
        }
        await file.writeAsBytes(bytes);
        onDone(utf8.decode(bytes));
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
}
