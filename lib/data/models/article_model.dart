class ArticleModel {
  final String title;
  final String sourceName;
  final String author;
  final String description;
  final String urlToImage;
  final String content;
  final String category;

  ArticleModel({
    required this.title,
    required this.sourceName,
    required this.author,
    required this.description,
    required this.urlToImage,
    required this.content,
    required this.category,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json, {required String defaultCategory}) {
    return ArticleModel(
      title: json['title'] ?? 'No Title',
      sourceName: json['sourceName'] ?? 'Unknown Source',
      author: json['author'] ?? 'Unknown Author',
      description: json['description'] ?? 'No Description',
      urlToImage: json['urlToImage'] ?? '',
      content: json['content'] ?? 'No content available.',
      category: json['category'] ?? 'general',
    );
  }
}