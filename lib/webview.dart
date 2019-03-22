import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:tropebrowser/preferences.dart';
import 'package:tropebrowser/searchbar.dart';

class TVTropeWidget extends StatefulWidget {
  TVTropeWidget({Key key, this.url}) : super(key: key);
  final String url;

  @override
  TropeState createState() => TropeState();
}

class TropeState extends State<TVTropeWidget> {
  final FlutterWebviewPlugin _fwp = new FlutterWebviewPlugin();

  String title = "Loading...";

  Future handlePreferences() async {
    if (TropePreferences.darkmodeEnabled) {
      await _fwp.evalJavascript(
          'document.querySelector("#user-prefs").classList.add("night-vision")');
    }
    if (TropePreferences.showSpoilersEnabled) {
      await _fwp.evalJavascript(
          'document.querySelector("#user-prefs").classList.add("show-spoilers")');
    }
  }

  void setTitle(String newTitle) {
    setState(() => title = newTitle);
  }

  @override
  void initState() {
    super.initState();
    _fwp.onStateChanged.listen((WebViewStateChanged state) async {
      if (state.type == WebViewState.finishLoad) {
        String tropeCleaner = await rootBundle.loadString('assets/js/filter.js');
        String title = (await _fwp.evalJavascript('document.querySelector(".entry-title").textContent.trim()')) ??
            (await _fwp.evalJavascript(
                'document.querySelector("meta[property="og:title"]").attributes["content"].trim()'));
        await handlePreferences().then((s) async {
          await _fwp.evalJavascript(tropeCleaner).then((s) async {
            await _fwp.show();
          });
        });

        setTitle(title.replaceAll('"', '').replaceAll("\\n", ''));
      }
      if (state.type == WebViewState.startLoad) {
        await _fwp.hide();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.url,
      appBar: TropeAppBar(title: title),
      withJavascript: true,
      hidden: true,
      scrollBar: false,
      initialChild: Stack(children: [
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
      ]),
    );
  }
}
