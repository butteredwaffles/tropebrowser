import 'package:flutter/material.dart';
import 'package:tropebrowser/main.dart';
import 'package:tropebrowser/save_feature.dart';
import 'package:tropebrowser/settingswidget.dart';
import 'package:tropebrowser/webview.dart';

const String RANDOM_URL = "https://tvtropes.org/pmwiki/randomitem.php?p=1";
ArticleManager _manager = ArticleManager();

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
        }),
        Divider(height: 20.0, indent: 2.0, color: Theme.of(context).dividerColor)
      ],
    )
  );
}

Future<Drawer> getRightDrawer(BuildContext context, Function setState) async {
  List<ArticleInfo> articles = await _manager.getArticles();
  return Drawer(
      child: ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: Theme.of(context).dividerColor,
        ),
        itemCount: articles.length,
        itemBuilder: (BuildContext ctx, int index) {
          return ListTile(
              title: Text(articles[index].title),
              trailing: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _manager.removeArticle(articles[index]);
                    setState(() => {});
                  }
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => TVTropeWidget(url: articles[index].url)));
              }
          );
        },
      )
  );
}
