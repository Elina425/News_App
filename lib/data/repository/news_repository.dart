import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/article_model.dart';

class NewsRepository {
  final String apiKey = "d07eacefa48b49f99c32f234069a0aa1";
  final String baseUrl = "https://newsapi.org/v2/top-headlines";

  final List<ArticleModel> _localCache = [];

  List<ArticleModel> get cachedArticles => _localCache;


  Future<List<ArticleModel>> fetchNews({String category = '', String query = ''}) async {
    String url = '$baseUrl?country=us&apiKey=$apiKey';

    if (category.isNotEmpty) {
      url += '&category=$category';
    }
    if (query.isNotEmpty) {
      url += '&q=$query';
    }

    if (apiKey.isEmpty || apiKey == "YOUR_API_KEY_HERE") {
      throw Exception("API Key is missing. Please replace 'YOUR_API_KEY_HERE' in NewsRepository.");
    }

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'error') {
          throw Exception(jsonResponse['message'] ?? 'API Error Occurred.');
        }

        final articlesJson = jsonResponse['articles'] as List;

        final articles = articlesJson
            .map((articleJson) => ArticleModel.fromJson(articleJson as Map<String, dynamic>, defaultCategory: category.isEmpty ? 'general' : category))
            .toList();

        if (query.isEmpty) {
          _localCache.clear();
          _localCache.addAll(articles);
        }

        return articles;
      } else {
        throw Exception('Failed to load news: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network or parsing error: $e');
    }
  }

  Future<List<ArticleModel>> searchLocally(String query) async {
    if (_localCache.isEmpty) return [];

    if (query.isEmpty) return _localCache;

    return _localCache.where((a) =>
    a.title.toLowerCase().contains(query.toLowerCase()) ||
        a.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
