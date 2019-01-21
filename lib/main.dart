import 'package:flutter/material.dart';
import 'package:tropebrowser/searchbar.dart';
import 'package:tropebrowser/webview.dart';

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
      title: TextStyle(fontSize: 30.0, fontStyle: FontStyle.italic, color: lightColors["darkblue"]),
      body1: TextStyle(fontSize: 13.0, color: lightColors["darkblue"]),
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<_MainPageState> myState = GlobalKey<_MainPageState>();
  String _url = "";
  String title = "Trope Browser";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TropeAppBar(title: title),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Enter in a trope URL or use the search bar above!", style: Theme.of(context).textTheme.caption),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                child: TextFormField(
                  onSaved: (v) => _url = v,
                )
              ),
              RaisedButton(
                child: Text("Open Trope"),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TVTropeWidget(url: _url)));
                  }
                },
              )
            ]
          )
        )
      )
    );
  }

}
