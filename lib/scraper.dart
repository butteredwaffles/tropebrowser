import 'dart:convert'; // Contains the JSON encoder
import 'package:http/http.dart'; // Contains a client for making API calls
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart'; // Contains DOM related classes for extracting data from elements


// Reference URL: https://tvtropes.org/pmwiki/pmwiki.php/Main/CameraAbuse
String RANDOM_URL = "https://tvtropes.org/pmwiki/randomitem.php?p=1";
Client client = Client();


Future<String> getLink(String url) async {
  Response response = await client.get(url);
  var document = parse(response.body);
  List<Element> main = document.querySelectorAll("#main-article p)");
  String result = "";
  main.forEach((ele) => result += "${ele.text}\n");
  return result;
}