import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'; // Contains a client for making API calls
import 'package:html/parser.dart'
    as parser; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart'
    as dom; // Contains DOM related classes for extracting data from elements

Client client = Client();
const String BASE = "https://tvtropes.org";

class TVTropeWidget extends StatefulWidget {
  TVTropeWidget({Key key, this.url}) : super(key: key);
  final String url;

  @override
  TVTrope createState() => TVTrope();
}

class TVTrope extends State<TVTropeWidget> {
  bool _loading = true;
  var folderVisibility = new Map<String, bool>();
  List<Widget> articleData;
  String articleTitle;
  ThemeData theme;

  Future openNewPage(String url) async {
    Navigator.push(context, MaterialPageRoute(builder: (_) => TVTropeWidget(url: url)));
  }

  Future<List<Widget>> getPage() async {
    Response response = await client.get(widget.url);
    var document = parser.parse(response.body);
    String title = document
        .querySelector(".entry-title")
        .text.trim(); // Title must be accessed separate from the document
    articleTitle = title;
    List<Widget> widgets = [
      Center(child: Container(padding: EdgeInsets.all(10.0), child: Text(title, style: theme.textTheme.title))),
      getSubpageWidget(document),
      getArticleImageWidget(document),
      getBodyParagraphWidget(document),
    ];

    return widgets;
  }

  DropdownMenuItem<String> _parseInnerSubpageLink(dom.Element element) {
    String text = element.querySelector(".wrapper").text;
    return DropdownMenuItem<String>(
        value: element.attributes["href"], child: Text(text, style: theme.textTheme.body1));
  }

  Widget getSubpageWidget(dom.Document document) {
    var subpageitems = List<DropdownMenuItem<String>>();
    for (var element in document.querySelectorAll(".subpage-link")) {
      subpageitems.add(_parseInnerSubpageLink(element));
    }

    var subdropdown = DropdownButton<String>(
      items: subpageitems,
      hint: Text("Subpages", style: theme.textTheme.body1),
      onChanged: (v) async => await openNewPage(BASE + v), // TODO: Switch to the article link once changed.
      isDense: false,
    );

    return Container(
        child: Column(children: [subdropdown], mainAxisSize: MainAxisSize.min),
        width: 100);
  }

  Widget getArticleImageWidget(dom.Document document) {
    dom.Element image = document.querySelector(".quoteright");
    dom.Element caption = document.querySelector(".acaptionright");
    // TODO: Add support for twikilinks in caption.
    List<Widget> colchildren;
    double width = 300;
    bool linkInCaption = caption?.querySelector("a") != null;

    if (image != null && caption != null) {
      colchildren = [
        Image.network(image.querySelector("img").attributes['src'],
            width: width),
        RichText(
            text: TextSpan(children: [
          linkInCaption
              ? handleTwikiLinks(
                  caption.text, caption.querySelector("a").attributes["href"],
                  style: theme.textTheme.caption)
              : TextSpan(text: caption.text.replaceAll("note", ""), style: theme.textTheme.caption)
        ]))
      ];
    } else if (image != null) {
      colchildren = [
        Image.network(image.querySelector("img").attributes['src'],
            width: width)
      ];
    } else if (caption != null) {
      colchildren = [
        RichText(
            text: TextSpan(children: [
          linkInCaption
              ? handleTwikiLinks(
                  caption.text.replaceAll("note", ""), caption.querySelector("a").attributes["href"],
                  style: theme.textTheme.caption)
              : TextSpan(text: caption.text, style: theme.textTheme.caption)
        ]))
      ];
    } else {
      return Container(width: 0, height: 0);
    }

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: colchildren),
      ),
    );
  }

  Widget getBodyParagraphWidget(dom.Document document) {
    var paragraphs = document
        .querySelectorAll(
            '#main-article p, #main-article p+*:not(.proper-ad-unit):not(hr), #main-article > .indent, .folderlabel, #main-article h2')
        .where((e) => e.text.replaceAll(RegExp(r"\s"), "") != "");
    List<TextSpan> bodyWidgets = [];
    List<Widget> folderWidgets = [];
    RichText h2data = RichText(text: TextSpan(children: []));
    bool h2Trope = false;

    for (dom.Element paragraph in paragraphs) {
      if (paragraph.classes.any((str) => str == "folderlabel") && !paragraph.text.contains("all folders")) {
        folderWidgets.add(handleFolders(paragraph));
      }
      else if (paragraph.localName == "h2" && (paragraph.nextElementSibling.localName == "ul" || paragraph.nextElementSibling.localName == "ol")) {
        List<TextSpan> spans = new List<TextSpan>();
        spans.add(TextSpan(text: paragraph.text.trim()));
        spans.addAll(handleLiTags(paragraph.nextElementSibling));

        h2data = RichText(
          text: TextSpan(
            children: spans
          )
        );
        h2Trope = true;
      }
      else {
        if (!h2Trope) {
          for (var node in paragraph.nodes) {
            var n = handleNodes(
                node, paragraph.nodes[paragraph.nodes.length - 1].hashCode);
            bodyWidgets.addAll(n);
          }
        }
      }
    }

    List<dom.Element> externalSubpages =
        document.querySelectorAll("#main-article > ul > li > a");
    if (externalSubpages.length > 0) {
      //bodyWidgets.add(TextSpan(text: 'Examples: \n', style: theme.textTheme.body1.copyWith(fontWeight: FontWeight.bold)));
      for (var item in externalSubpages) {
        bodyWidgets.add(
            handleTwikiLinks("\t• ${item.text}\n", item.attributes["href"]));
      }
    }

    List<Widget> widgets = [
      RichText(text: TextSpan(children: bodyWidgets))
    ];
    widgets.addAll(folderWidgets);
    widgets.add(h2data);

    return Container(
        margin: EdgeInsets.all(5.0),
        width: MediaQuery.of(context).size.width - 20,
        child: Column(
          children: widgets
        )
    );
  }

  List<TextSpan> handleLiTags(dom.Element selector) {
    List<TextSpan> items = [];
    for (var item in selector.querySelectorAll("li")) {
      items.add(TextSpan(text: "\t•", style: theme.textTheme.body1));
      for (var node in item.nodes) {
        items.addAll(handleNodes(node, -1));
      }
      items.add(TextSpan(text: "\n", style: theme.textTheme.body1));
    }
    return items;
  }

  Widget handleFolders(dom.Element folder) {
    String text = folder.text.trim();
    if (!folderVisibility.containsKey(text)) {
      folderVisibility[text] = false;
    }

    List<TextSpan> items = new List<TextSpan>();
    var selector = folder.nextElementSibling.attributes["isfolder"] != null ? folder.nextElementSibling : folder.nextElementSibling.nextElementSibling;
    items.addAll(handleLiTags(selector));


    return Container(
      child: Column(
        children: [
          Center(
            child: Container(
              height: 60,
              child: FlatButton(
                child: Text(text),
                onPressed: () {
                  folderVisibility[text] = !folderVisibility[text];
                  setState(() {
                    _loadArticle().then((_) {});
                    print("changing visibility for "+folder.toString() + " to " + folderVisibility[folder].toString());
                  });
                }
              )
            ),
          ),
          folderVisibility[text] ? Center(
            child: Container(
              padding: EdgeInsets.all(13.0),
              child: RichText(
                text: TextSpan(
                  children: items
                )
              )
            )
          ) : Container(width: 0, height: 0)
        ]
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.all(Radius.circular(15.0))
      ),
      margin: EdgeInsets.only(bottom: 5.0, top: 5.0),
    );
  }

  List<TextSpan> handleNodes(dom.Node node, int finalHashCode) {
    List<TextSpan> bodyWidgets = [];

    if (node.attributes["class"] != null &&
        node.attributes["class"] == "indent") {
      node.text = "    " + node.text;
    }
    // For italicized words
    if (node.toString().contains("<html em>")) {
      if (node.children.length > 0 && node.children[0].localName == "a") {
        bodyWidgets.add(handleTwikiLinks(
            node.text, node.children[0].attributes["href"],
            italicize: true));
      } else {
        bodyWidgets.add(TextSpan(
            text: node.text,
            style: theme.textTheme.body1
                .copyWith(fontStyle: FontStyle.italic)));
      }
    }
    // Handle lists, which sometime appear in article bodies
    else if (node.toString().contains("<html li>")) {
      bodyWidgets.add(TextSpan(
          text: "\t• ${node.text}\n", style: theme.textTheme.body1));
    }
    // Handle links
    else if (node.attributes.containsKey("href")) {
      bodyWidgets.add(handleTwikiLinks(node.text, node.attributes["href"],
          italicize: false));
    }
    else if (node.toString().contains("<html br")) {
      bodyWidgets.add(TextSpan(text: "\n", style: theme.textTheme.body1));
    }
    // Handle text nodes
    else {
      bodyWidgets
          .add(TextSpan(text: node.text, style: theme.textTheme.body1));
    }

    // Add an extra space once everything else is done
    if (node.hashCode == finalHashCode) {
      bodyWidgets.add(TextSpan(text: '\n'));
    }
    return bodyWidgets;
  }

  TextSpan handleTwikiLinks(String text, String url,
      {bool italicize = false, TextStyle style}) {
    var defaultStyle = theme.textTheme.body1.copyWith(
        color: Colors.blue,
        fontStyle: (italicize ? FontStyle.italic : FontStyle.normal));
    return TextSpan(
        text: text,
        style: style == null ? defaultStyle : style.merge(defaultStyle),
        recognizer: TapGestureRecognizer()
          ..onTap = () => openNewPage(
              (url.contains(BASE) ? url : BASE + url)) // Cover my own behind
        );
  }

  @override
  void initState() {
    super.initState();
    _loadArticle().then((_) => {});
  }

  Widget buildWidget() {
    if (_loading) {
      return Stack(children: [
        Opacity(
            opacity: 0.7,
            child: const ModalBarrier(dismissible: false, color: Colors.black)),
        Center(
            child: SizedBox(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                width: 75,
                height: 75)),
      ]);
    } else {
      return Container(width: 0, height: 0);
    }
  }

  Future _loadArticle() async {
    while (theme == null) {
      await Future.delayed(Duration(seconds: 1));
    }
    List<Widget> data = await getPage();

    setState(() {
      _loading = false;
      articleData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    List<Widget> children = [
      Container(
          child: buildWidget(), height: MediaQuery.of(context).size.height)
    ];
    articleData == null
        ? Container(width: 0, height: 0)
        : children = articleData;

    return Scaffold(
      appBar: AppBar(
        title: Text(articleTitle == null ? "" : articleTitle),
      ),
      body: Center(
        child: ListView(
          children: children,
        ),
      ),
    );
  }
}
