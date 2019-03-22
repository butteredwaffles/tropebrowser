import 'package:flutter/material.dart';
import 'package:tropebrowser/drawers.dart';
import 'package:tropebrowser/preferences.dart';

class SettingsScreen extends StatefulWidget {
  final String title = "Trope Browser";

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      drawer: getLeftDrawer(context),
      endDrawer: FutureBuilder(
        future: getRightDrawer(context, setState),
        builder: (BuildContext ctx, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return snapshot.data;
          } else {return Container(width: 0.0, height: 0.0);}
        },
      ),
      body: ListView(
        children: <Widget>[
          CheckboxListTile(
            subtitle: Text("Changes the theme of the app. Takes effect upon restart."),
            title: Text("Toggle Dark Mode"),
              value: TropePreferences.darkmodeEnabled,
              onChanged: (val) {
                setState(() {
                  TropePreferences.darkmodeEnabled = val;
                });
              }),
          CheckboxListTile(
            subtitle: Text("Automatically show spoilers or hide them by default."),
            title: Text("Toggle Spoilers"),
            value: TropePreferences.showSpoilersEnabled,
            onChanged: (val) {
              setState(() {
                TropePreferences.showSpoilersEnabled = val;
              });
            }
          )
        ],
      )
    );
  }

}