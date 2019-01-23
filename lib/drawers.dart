import 'package:flutter/material.dart';
import 'package:tropebrowser/main.dart';
import 'package:tropebrowser/settingswidget.dart';
import 'package:tropebrowser/webview.dart';

const String RANDOM_URL = "https://tvtropes.org/pmwiki/randomitem.php?p=1";

Drawer getLeftDrawer(BuildContext context) {

  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Center(child: Text("Trope Browser", style: Theme.of(context).textTheme.title)),
        ),
        ListTile(title: Text("Main"), onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage()));
        }),
        ListTile(title: Text("Random"), onTap: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => TVTropeWidget(url: RANDOM_URL)));
        }),
        ListTile(title: Text("Settings"), onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
        })
      ],
    )
  );
}