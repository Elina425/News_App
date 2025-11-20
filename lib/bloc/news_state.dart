import '../data/models/article_model.dart';
import 'package:equatable/equatable.dart';

enum NewsStatus { initial, loading, loaded, error }

class NewsState extends Equatable {
  final NewsStatus status;
  final List<ArticleModel> articles;
  final String selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  const NewsState({
    this.status = NewsStatus.initial,
    this.articles = const [],
    this.selectedCategory = '',
    this.searchQuery = '',
    this.errorMessage,
  });

  NewsState copyWith({
    NewsStatus? status,
    List<ArticleModel>? articles,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
  }) {
    return NewsState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, articles, selectedCategory, searchQuery,errorMessage];
}