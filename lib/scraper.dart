import 'package:flutter/gestures.dart';
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

  TVTrope(String uri, ThemeData them) {
    url = uri;
    theme = them;
  }

  Future openNewPage(String url) async {
    // TODO: Open new trope page on twikilink open
  }

  Future<List<Widget>> getPage() async {
    Response response = await client.get(url);
    var document = parser.parse(response.body);
    String title = document
        .querySelector(".entry-title")
        .text; // Title must be accessed separate from the document
    List<Widget> widgets = [
      Center(child: Text(title, style: theme.textTheme.title)),
      getSubpageWidget(document),
      getArticleImageWidget(document),
      getBodyParagraphWidget(document),
    ];

    return widgets;
  }

  DropdownMenuItem<String> _parseInnerSubpageLink(dom.Element element) {
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
        width: 100
    );
  }

  Widget getArticleImageWidget(dom.Document document) {
    dom.Element image = document.querySelector(".quoteright");
    dom.Element caption = document.querySelector(".acaptionright");
    // TODO: Add support for twikilinks in caption.
    List<Widget> colchildren;
    double width = 300;

    if (image != null && caption != null) {
      colchildren = [
        Image.network(image
            .querySelector("img")
            .attributes['src'], width: width),
        Text(caption.text, style: theme.textTheme.caption)
      ];
    }
    else if (image != null) {
      colchildren = [Image.network(image
          .querySelector("img")
          .attributes['src'], width: width)
      ];
    }
    else if (caption != null) {
      colchildren = [Text(caption.text, style: theme.textTheme.caption)];
    }
    else {
      return Container(width: 0, height: 0);
    }

    return Align(
      alignment: Alignment.topCenter,
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

  Widget getBodyParagraphWidget(dom.Document document) {
    var paragraphs = document.querySelectorAll("#main-article p, #main-article p+*:not(div):not(hr)").where((e) => e.text.replaceAll(RegExp(r"\s"), "") != "");
    List<TextSpan> bodyWidgets = [];

    for (dom.Element paragraph in paragraphs) {
      for (var node in paragraph.nodes) {
        // For italicized words
        if (node.toString().contains("<html em>")) {
          if (node.children.length > 0 && node.children[0].localName == "a") {
            bodyWidgets.add(handleTwikiLinks(
                node.text,
                node.children[0].attributes["href"],
                italicize: true
            ));
          }
          else {
            bodyWidgets.add(TextSpan(text: node.text, style: theme.textTheme.body1.copyWith(fontStyle: FontStyle.italic)));
          }
        }
        // Handle lists, which sometime appear in article bodies
        else if (node.toString().contains("<html li>")) {
          bodyWidgets.add(TextSpan(text: "\t• ${node.text}\n", style: theme.textTheme.body1));
        }
        // Handle links
        else if (node.attributes.containsKey("href")) {
          bodyWidgets.add(handleTwikiLinks(
              node.text,
              node.attributes["href"],
              italicize: false
          ));
        }
        // Handle text nodes
        else {
          bodyWidgets.add(TextSpan(text: node.text, style: theme.textTheme.body1));
        }

        // Add an extra space once everything else is done
        if (node.hashCode == paragraph.nodes[paragraph.nodes.length - 1].hashCode) {
          bodyWidgets.add(TextSpan(text: '\n'));
        }
      }
    }

    List<dom.Element> externalSubpages = document.querySelectorAll("#main-article > ul > li > a");
    if (externalSubpages.length > 0 ) {
      //bodyWidgets.add(TextSpan(text: 'Examples: \n', style: theme.textTheme.body1.copyWith(fontWeight: FontWeight.bold)));
      for (var item in externalSubpages) {
        bodyWidgets.add(handleTwikiLinks("\t• ${item.text}\n", item.attributes["href"]));
      }
    }

    return Container(
      padding: EdgeInsets.all(15.0),
      child: RichText(
        text: TextSpan(
          children: bodyWidgets
        )
      )
    );
  }

  TextSpan handleTwikiLinks(String text, String url, {bool italicize = false}) {
    return TextSpan(
      text: text,
      style: theme.textTheme.body1.copyWith(color: Colors.blue, fontStyle: (italicize ? FontStyle.italic : FontStyle.normal)),
      recognizer: TapGestureRecognizer()..onTap = () => openNewPage((url.contains(BASE) ? url : BASE + url)) // Cover my own behind
    );
  }
}
