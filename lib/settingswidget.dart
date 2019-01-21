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
      body: ListView(
        children: <Widget>[
          CheckboxListTile(
            subtitle: Text("Changes the theme of the app. Takes effect upon restart."),
            title: Text("Toggle Dark Mode"),
              value: TropePreferences.darkmodeEnabled,
              onChanged: (val) {
                TropePreferences.darkmodeEnabled = val;
                setState(() {

                });
              })
        ],
      )
    );
  }

}