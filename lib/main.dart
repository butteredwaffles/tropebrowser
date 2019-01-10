import 'package:flutter/material.dart';
import 'package:tropebrowser/scraper.dart';

void main() => runApp(TropeBrowser());

Map<String, Color> lightColors = {
  "white": Color(0xffffffff),
  "lightblue": Color(0xffd0e1f9),
  "blue": Color(0xff4d648d),
  "darkishblue": Color(0xff283655),
  "darkblue": Color(0xff1e1f26)
};


class TropeBrowser extends StatelessWidget {
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightColors["lightblue"],
    accentColor: lightColors["blue"],
    backgroundColor: lightColors["darkblue"],

    fontFamily: 'Helvetica',
    textTheme: TextTheme(
      headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: lightColors["darkblue"]),
      title: TextStyle(fontSize: 50.0, fontStyle: FontStyle.italic, color: lightColors["darkblue"]),
      body1: TextStyle(fontSize: 16.0, color: lightColors["darkblue"]),
    )
  );


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trope Browser',
      theme: lightTheme,
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  final String title = "Trope Browser";

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _loading = true;
  String articleText = "";
  ThemeData theme;


  Widget buildWidget() {
    if (_loading) {
      return Stack(
        children: [
          Opacity(opacity: 0.3, child: const ModalBarrier(dismissible: false, color: Colors.grey)),
          Center(child: CircularProgressIndicator()),
          Text("Loading...", style: theme.textTheme.body1) // Theme will be set by the time this function gets run.
        ]
      );
    }
    else {
      return Container(width: 0, height: 0);
    }
  }

  Future _loadArticle() async {
    String text = await getLink("https://tvtropes.org/pmwiki/pmwiki.php/Main/CameraAbuse");

    setState(() {
      _loading = false;
      articleText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: [
            RaisedButton(
              onPressed: _loadArticle,
              child: Text("Load Test Article", style: theme.textTheme.body1)
            ),
            Text(articleText, style: theme.textTheme.body1)
          ]
        ),
      ),
    );
  }
}
