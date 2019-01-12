import 'package:flutter/material.dart';
import 'package:tropebrowser/scraper.dart';

// Reference URL: https://tvtropes.org/pmwiki/pmwiki.php/Main/CameraAbuse
const String RANDOM_URL = "https://tvtropes.org/pmwiki/randomitem.php?p=1";

void main() => runApp(TropeBrowser());


Map<String, Color> lightColors = {
  "white": Color(0xffffffff),
  "lightblue": Color(0xffd0e1f9),
  "blue": Color(0xff4d648d),
  "darkishblue": Color(0xff283655),
  "darkblue": Color(0xff1e1f26)
};


class TropeBrowser extends StatelessWidget {
  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: lightColors["lightblue"],
    accentColor: lightColors["blue"],
    backgroundColor: lightColors["darkblue"],

    fontFamily: 'Helvetica',
    textTheme: TextTheme(
      headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold, color: lightColors["darkblue"]),
      title: TextStyle(fontSize: 50.0, fontStyle: FontStyle.italic, color: lightColors["darkblue"]),
      body1: TextStyle(fontSize: 16.0, color: lightColors["darkblue"]),
      caption: TextStyle(fontSize: 14.0, color: lightColors["darkblue"], fontStyle: FontStyle.italic)
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
  List<Widget> articleData;
  ThemeData theme;

  @override
  void initState() {
    _loadArticle().then((_) => {});
  }


  Widget buildWidget() {
    if (_loading) {
      return Stack(
        children: [
          Opacity(opacity: 0.7, child: const ModalBarrier(dismissible: false, color: Colors.black)),
          Center(child: SizedBox(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            width: 75,
            height: 75)
          ),
        ]
      );
    }
    else {
      return Container(width: 0, height: 0);
    }
  }

  Future _loadArticle() async {
    while (theme == null) {
      await Future.delayed(Duration(seconds: 1));
    }
    List<Widget> data = await TVTrope("https://tvtropes.org/pmwiki/pmwiki.php/Main/CameraAbuse", theme).getPage();

    setState(() {
      _loading = false;
      articleData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);

    List<Widget> children = [Container(child: buildWidget(), height: MediaQuery.of(context).size.height)];

    articleData == null ? Container(width: 0, height: 0) : children = articleData;


    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: children,
        ),
      ),
    );
  }
}
