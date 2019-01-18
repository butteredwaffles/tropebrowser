import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:http/http.dart'; // Contains a client for making API calls
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom; // Contains DOM rel

class TVTropeWidget extends StatefulWidget {
  TVTropeWidget({Key key, this.url}) : super(key: key);
  final String url;

  @override
  TVTrope createState() => TVTrope();
}

class TVTrope extends State<TVTropeWidget> {
  String title = "Loading...";
  InAppWebViewController controller;
  dom.Document document;
  Client client = Client();

  Future onViewCreated(InAppWebViewController contr) async {
    controller = contr;
    await getTitle();
  }

  Future onUrlLoading(InAppWebViewController contr, String url) async {
    await getTitle();
  }

  Future getTitle() async {
    Response response = await client.get((await controller?.getUrl()) ?? widget.url);
    var document = parser.parse(response.body);
    setTitle(document.querySelector(".entry-title").text.trim());
  }

  void setTitle(String str) {
    setState(() {
      title = str;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title)
      ),
      body: Container(
        child: InAppWebView(
          initialUrl: widget.url,
          onWebViewCreated: onViewCreated,
          onLoadStart: onUrlLoading,
        ),
      )
    );
  }

}