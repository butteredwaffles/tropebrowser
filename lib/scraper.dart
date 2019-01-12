import 'package:flutter/material.dart';
import 'package:http/http.dart'; // Contains a client for making API calls
import 'package:html/parser.dart'
as parser; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart'
as dom; // Contains DOM related classes for extracting data from elements

Client client = Client();
const String BASE = "https://tvtropes.org";

class TVTrope {
  String url = "";
  ThemeData theme;
  Map<dom.Element, String> _tropeLinks = Map<dom.Element, String>();

  TVTrope(String uri, ThemeData them) {
    url = uri;
    theme = them;
  }

  Future<List<Widget>> getPage() async {
    Response response = await client.get(url);
    var document = parser.parse(response.body);
    String title = document
        .querySelector(".entry-title")
        .text; // Title must be accessed separate from the document
    List<Widget> widgets = [
      Text(title, style: theme.textTheme.title),
      getSubpageWidget(document),
      getArticleImageWidget(document)
    ];


    //var article = document.querySelector("#main-article");
    //List<dom.Element> allArticleElements = article.querySelectorAll("*");

    return widgets;
  }

  DropdownMenuItem<String> _parseInnerSubpageLink(dom.Element element) {
    _tropeLinks[element] = BASE + element.attributes["href"];
    String text = element
        .querySelector(".wrapper")
        .text;
    print(text);
    return DropdownMenuItem<String>(
        value: text, child: Text(text, style: theme.textTheme.body1));
  }

  Widget getSubpageWidget(dom.Document document) {
    var subpageitems = List<DropdownMenuItem<String>>();
    for (var element in document.querySelectorAll(".subpage-link")) {
      subpageitems.add(_parseInnerSubpageLink(element));
    }

    var subdropdown = DropdownButton<String>(
      items: subpageitems,
      hint: Text("Subpages", style: theme.textTheme.body1),
      onChanged: (_) {}, // TODO: Switch to the article link once changed.
      isDense: false,
    );

    return Container(
        child: Column(
            children: [subdropdown],
            mainAxisSize: MainAxisSize.min
        ),
        height: 48,
        width: 100
    );
  }

  Widget getArticleImageWidget(dom.Document document) {
    dom.Element image = document.querySelector(".quoteright");
    dom.Element caption = document.querySelector(".acaptionright");
    // TODO: Add support for twikilinks in caption.
    List<Widget> colchildren;

    if (image != null && caption != null) {
      colchildren = [
        Image.network(image
            .querySelector("img")
            .attributes['src'], width: 190),
        Text(caption.text, style: theme.textTheme.caption)
      ];
    }
    else if (image != null) {
      colchildren = [Image.network(image
          .querySelector("img")
          .attributes['src'], width: 190)
      ];
    }
    else if (caption != null) {
      colchildren = [Text(caption.text, style: theme.textTheme.caption)];
    }
    else {
      return Container(width: 0, height: 0);
    }

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(15.0))
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: colchildren
        ),
      ),
    );
  }
}
