import 'package:flutter/material.dart';
import 'package:tropebrowser/webview.dart';

class TropeAppBar extends StatefulWidget implements PreferredSizeWidget {
  TropeAppBar({ Key key, this.title}) : super(key: key);

  final String title;
  @override
  _TropeAppBarState createState() => new _TropeAppBarState();

  @override
  Size get preferredSize => AppBar().preferredSize;


}

class _TropeAppBarState extends State<TropeAppBar>
{
  Widget appBarTitle;
  Icon actionIcon = new Icon(Icons.search);
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
  bool _titleIsTextField = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_titleIsTextField) {
      appBarTitle = Text(widget.title);
    }
    return buildBar(context);
  }


  Widget buildBar(BuildContext context) {
    return new AppBar(
        title: appBarTitle,
        actions: <Widget>[
          new IconButton(icon: actionIcon, onPressed: () {
            setState(() {
              if (this.actionIcon.icon == Icons.search) {
                _titleIsTextField = true;
                this.actionIcon = new Icon(Icons.close);
                this.appBarTitle = new TextField(
                  autofocus: true,
                  controller: _searchQuery,
                  onSubmitted: search,
                  decoration: new InputDecoration(
                      prefixIcon: new Icon(Icons.search, color: Colors.black),
                      hintText: "Search TVTropes...",
                  ),
                );
              }
              else {
                _handleSearchEnd();
              }
            });
          },),
        ]
    );
  }

  void _handleSearchEnd() {
    setState(() {
      _titleIsTextField = false;
      this.actionIcon = new Icon(Icons.search);
      this.appBarTitle = Text(widget.title);
      _searchQuery.clear();
    });
  }

  void search(String searchTerm) {
    _handleSearchEnd();
    Navigator.push(context, MaterialPageRoute(builder: (context) => TVTropeWidget(url: "https://tvtropes.org/pmwiki/elastic_search_result.php?q=$searchTerm&page_type=all&search_type=article")));
  }

}
