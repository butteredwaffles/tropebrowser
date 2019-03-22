import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tropebrowser/drawers.dart';
import 'package:tropebrowser/preferences.dart';
import 'package:tropebrowser/save_feature.dart';
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
  ArticleManager _articleManager = ArticleManager();

  String title = "Loading...";

  /// Alters the Javascript of the page to match the user-specified settings.
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

    /// This is shown while the Webview is not ready. These two elements are removed once it is.
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
    bool isSearchResult = _nextArticleLoad.contains("elastic_search_result");

    WebView view = WebView(
      initialUrl: widget.url,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (webViewController) {
        _controller = webViewController;
      },
      onPageStarted: (url) async {
        setState(() {
          _fullyFinished = false;
          _nextArticleLoad = url;
        });
        String snackText = isSearchResult ? "Loading search results..." : "Loading...\n" + _nextArticleLoad;
        final SnackBar bar = new SnackBar(
          content: Text(snackText),
          duration: Duration(seconds: 1),
        );
        _scaffoldKey.currentState.showSnackBar(bar);

      },
      onPageFinished: (str) async {
        String tropeCleaner = await rootBundle.loadString('assets/js/filter.js');

        // If this is an article, it will be the first option. If it's search results, it will be the second.
        String _possTitle1 = await _controller.evaluateJavascript('document.querySelector(".entry-title").textContent.trim()');
        String _possTitle2 = await _controller.evaluateJavascript('document.querySelector("head > meta:nth-child(15)").attributes["content"].value');

        String nTitle;
        if (_possTitle1 != "null") {
          nTitle = _possTitle1;
        }
        else {
          print(_possTitle2);
          nTitle = _possTitle2;
        }
        await handlePreferences().then((s) async {
          await _controller.evaluateJavascript(tropeCleaner).then((s) async {
            // Without this delay, it flashes before switching to the edited page.
            await Future.delayed(Duration(milliseconds: 300));
            setTitle(nTitle.replaceAll('"', '').replaceAll("\\n", ''));
            isSearchResult && title != "Loading..." ? null :
                (await _articleManager.getArticles()).where((a) => a.title == title).length == 0
                    ? await _articleManager.addArticle(ArticleInfo(title, str)) : null;
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
      endDrawer: FutureBuilder(
        future: getRightDrawer(context, setState),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return snapshot.data;
          }
          else {return Container(width: 0.0, height: 0.0);}
        },
      ),
      body: placeholder
    );
  }
}
