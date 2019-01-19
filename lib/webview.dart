import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:http/http.dart'; // Contains a client for making API calls
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom; // Contains DOM rel
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tropebrowser/preferences.dart';

class TVTropeWidget extends StatefulWidget {
  TVTropeWidget({Key key, this.url}) : super(key: key);
  final String url;

  @override
  TVTrope createState() => TVTrope();
}

class TVTrope extends State<TVTropeWidget> {
  TropePreferences preferences;

  String title = "Loading...";
  InAppWebViewController controller;
  dom.Document document;
  Client client = Client();
  // Until we can figure out how to implement smooth loading...
  bool _loading = false;

  Future onViewCreated(InAppWebViewController contr) async {
    controller = contr;
    await loadUrl();
  }

  Future onUrlLoading(InAppWebViewController contr, String url) async {
    await loadUrl();
  }

  Future loadUrl() async {
    Response response = await client.get(
        (await controller?.getUrl()) ?? widget.url);
    var document = parser.parse(response.body);
    setTitle(document
        .querySelector(".entry-title")
        .text
        .trim());
  }

  void setTitle(String str) {
    setState(() {
      title = str;
    });
  }

  Widget buildWidget() {
    if (_loading) {
      return Stack(children: [
        Opacity(
            opacity: 0.7,
            child: const ModalBarrier(dismissible: false, color: Colors.black)),
        Center(
            child: SizedBox(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                width: 75,
                height: 75)),
      ]);
    } else {
      return Container(width: 0, height: 0);
    }
  }

  Future handlePreferences() async {
    if (preferences.darkmodeEnabled) {
      await controller.injectScriptCode('document.querySelector("#user-prefs").classList.add("night-vision")');
    }
  }

  @override
  void initState() {
    super.initState();
    setPrefs();
  }

  Future setPrefs() async {
    preferences = TropePreferences(await SharedPreferences.getInstance());
    print(preferences);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title)
      ),
      body: InAppWebView(
          initialUrl: widget.url,
          onWebViewCreated: onViewCreated,
          onLoadStart: onUrlLoading,
          onLoadStop: (InAppWebViewController contr, String url) async {
            await contr.injectScriptCode(await rootBundle.loadString('assets/js/filter.js'));
            await handlePreferences();
          },
        onConsoleMessage: (InAppWebViewController contr, ConsoleMessage msg) {
          setState(() {
            print("ayy");
            _loading = false;
          });
        },
      )
    );
  }
}


class TVTropesBrowser extends InAppBrowser {
  @override
  void onBrowserCreated() async {
    print("Created browser client.");
  }

  @override
  void onLoadStart(String url) {
    print("Loading url '$url'.");
  }

}