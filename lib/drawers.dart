import 'package:flutter/material.dart';
import 'package:tropebrowser/main.dart';
import 'package:tropebrowser/settingswidget.dart';

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
        ListTile(title: Text("Settings"), onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
        })
      ],
    )
  );
}