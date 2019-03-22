import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tropebrowser/drawers.dart';
import 'package:tropebrowser/preferences.dart';
import 'package:tropebrowser/searchbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TVTropeWidget extends StatefulWidget {
  TVTropeWidget({Key key, this.url}) : super(key: key);
  final String url;

  @override
  TropeState createState() => TropeState();
}

class TropeState extends State<TVTropeWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  WebViewController _controller;
  bool _fullyFinished = false;

  String title = "Loading...";


  Future handlePreferences() async {
    if (TropePreferences.darkmodeEnabled) {
      await _controller.evaluateJavascript(
          'document.querySelector("#user-prefs").classList.add("night-vision")');
    }
    if (TropePreferences.showSpoilersEnabled) {
      await _controller.evaluateJavascript(
          'document.querySelector("#user-prefs").classList.add("show-spoilers")');
    }
  }

  void setTitle(String newTitle) {
    setState(() => title = newTitle);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    String _nextArticleLoad = "";

    Stack placeholder = Stack(children: [
      Opacity(
          opacity: .9,
          child: const ModalBarrier(dismissible: false, color: Colors.black)
      ),
      Center(
          child: SizedBox(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              width: 75,
              height: 75)),
    ]);

    WebView view = WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (webViewController) {
        _controller = webViewController;
      },
      onPageStarted: (url) {
        setState(() {
          _fullyFinished = false;
          _nextArticleLoad = url;
        });
        String snackText = _nextArticleLoad.contains("elastic_search_result") ? "Loading search results..." : "Loading...\n" + _nextArticleLoad;
        final SnackBar bar = new SnackBar(
          content: Text(snackText),
          duration: Duration(seconds: 1),
        );
        _scaffoldKey.currentState.showSnackBar(bar);
      },
      onPageFinished: (str) async {
        String tropeCleaner = await rootBundle.loadString('assets/js/filter.js');
        String title = (await _controller.evaluateJavascript('document.querySelector(".entry-title").textContent.trim()')) ??
            (await _controller.evaluateJavascript(
                'document.querySelector("meta[property="og:title"]").attributes["content"].trim()'));
        await handlePreferences().then((s) async {
          await _controller.evaluateJavascript(tropeCleaner).then((s) async {
            // It's going to flash if this isn't delayed, so just run with it
            await Future.delayed(Duration(milliseconds: 300));
            setTitle(title.replaceAll('"', '').replaceAll("\\n", ''));
            setState(() => _fullyFinished = true);
          });
        });
      },
    );

    placeholder.children.insert(0, view);
    if (_fullyFinished) {
      placeholder.children.removeRange(1, 3);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: TropeAppBar(title: title),
      drawer: getLeftDrawer(context),
      body: placeholder
    );
  }
}
