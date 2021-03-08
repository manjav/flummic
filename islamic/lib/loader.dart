import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class Loader {
  HttpClient httpClient;
  Future<Loader> load(String path, String url, Function(String) onDone,
      Function(double) onProgress, Function(String) onError) async {
    var baseURL = (await getApplicationSupportDirectory()).path;
    var file = new File('$baseURL/$path');
    if (await file.exists()) {
      var str = await file.readAsString();
      onDone(str);
      return this;
    }
    httpClient = new HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    var contentLength = response.contentLength;
    var bytes = <int>[];
    response.asBroadcastStream().listen(
      (List<int> newBytes) {
        bytes.addAll(newBytes);
        onProgress(bytes.length / contentLength);
      },
      onDone: () async {
        await file.writeAsBytes(bytes);
        onDone(utf8.decode(bytes));
      },
      onError: (e) {
        onError(e);
      },
      cancelOnError: true,
    );
    return this;
  }

  void abort() => httpClient?.close(force: true);
}
