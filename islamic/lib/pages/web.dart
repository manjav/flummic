import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:islamic/utils/localization.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  final dynamic? data;
  WebPage({Key? key, this.data}) : super(key: key);

  @override
  _WebPageState createState() => _WebPageState();
}

class _WebPageState extends State<WebPage> {
  bool loaded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.data["title"] ?? "")),
        body: Stack(alignment: Alignment.center, children: [
          WebView(
            allowsInlineMediaPlayback: true,
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (String url) {
                if (url == widget.data["url"]) {
                  loaded = true;
                  setState(() {});
                }
                if (url.indexOf("hidaya") > -1 || url.indexOf("islam") > -1)
                  Navigator.pop(context);
            },
              initialUrl: widget.data["url"]),
          loaded
              ? SizedBox()
              : Stack(alignment: Alignment.center, children: [
                  Container(
                    width: 240,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Color(0xAA000000),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  CircularProgressIndicator(
                      backgroundColor: Theme.of(context).backgroundColor),
                  Text("wait_l".l(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white))
                ])
        ]));
  }
}
