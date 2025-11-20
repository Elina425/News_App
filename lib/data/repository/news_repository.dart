import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/article_model.dart';

class NewsRepository {
  // NOTE: In a real app, use the 'http' package here for API calls.
  final String apiKey = "d07eacefa48b49f99c32f234069a0aa1";
  final String baseUrl = "https://newsapi.org/v2/top-headlines";

  // Part 1 only requires fetching the list, so we ignore search/category parameters.
  Future<List<ArticleModel>> fetchTopHeadlines() async {
    // Base URL setup for US top headlines
    final String url = '$baseUrl?country=us&apiKey=$apiKey';

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

        // Return the parsed list of articles
        return articlesJson
            .map((articleJson) => ArticleModel.fromJson(articleJson as Map<String, dynamic>))
            .toList();

      } else {
        throw Exception('Failed to load news: HTTP ${response.statusCode}');
      }
    } catch (e) {
      // Throw an error for the Cubit to handle in the UI
      throw Exception('Network error: Could not fetch data. $e');
    }
  }
}
