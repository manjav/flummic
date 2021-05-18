import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  final String? url;
  WebPage({Key? key, this.url}) : super(key: key);

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WebView(
            allowsInlineMediaPlayback: true,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String url) {
              if (url == "http://hidaya.sarand.net/") Navigator.pop(context);
            },
            initialUrl: widget.url));
  }
}
