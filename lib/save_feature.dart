import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';


class ArticleManager {
  static final ArticleManager _singleton = new ArticleManager._internal();
  static String dataPath;

  factory ArticleManager() {
    getApplicationDocumentsDirectory().then((dir) => dataPath = dir.path);
    return _singleton;
  }

  File get _saveFile {
    File file = File("$dataPath/articles.json");
    if (!file.existsSync()) {
      file.createSync();
    }
    return file;
  }

  Future<dynamic> _loadSaveFile() async {
    dynamic save;
    try {
      save = jsonDecode(await _saveFile.readAsString());
    }
    catch (FormatException) {
        save = {"articles": []};
    }
    return save;
  }

  Future _saveSaveFile(dynamic save) async {
    await _saveFile.writeAsString(jsonEncode(save));
  }

  Future addArticle(ArticleInfo info) async {
    dynamic save = await _loadSaveFile();
    save["articles"].add({"title": info.title, "url": info.url});
    _saveSaveFile(save);
  }

  Future removeArticle(ArticleInfo info) async {
    dynamic save = await _loadSaveFile();
    (save["articles"] as List<dynamic>).removeWhere((d) => d["title"].toString() == info.title);
    _saveSaveFile(save);
  }

  Future<List<ArticleInfo>> getArticles() async {
    List<ArticleInfo> articles = [];
    for (dynamic article in (await _loadSaveFile())["articles"]) {
      articles.add(ArticleInfo(article["title"], article["url"]));
    }
    return articles;
  }

  Future clearArticles() async {
    dynamic save = jsonEncode({"articles": []});
    _saveSaveFile(save);
  }

  ArticleManager._internal();
}

class ArticleInfo {
  String title;
  String url;

  ArticleInfo(this.title, this.url);
}