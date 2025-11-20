import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/article_model.dart';
import '../data/repository/news_repository.dart';
import 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository _repository;

  NewsCubit(this._repository) : super(const NewsState());

  Future<void> loadNews({bool isRefresh = false}) async {
    if (state.articles.isEmpty || isRefresh) {
      emit(state.copyWith(status: NewsStatus.loading, errorMessage: null));
    }

    emit(state.copyWith(searchQuery: ''));

    try {
      final articles = await _repository.fetchNews(
        category: state.selectedCategory,
        query: state.searchQuery,
      );

      emit(state.copyWith(
        status: NewsStatus.loaded,
        articles: articles,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NewsStatus.error,
        articles: _repository.cachedArticles,
        errorMessage: 'Network Error. Could not refresh news. Showing cached data.',
      ));
    }
  }
    void setSearchQuery(String query) {
      emit(state.copyWith(searchQuery: query, errorMessage: null));
      searchLocal(query);
    }

  void searchRemote() async {
    emit(state.copyWith(status: NewsStatus.loading, errorMessage: null));

    try {
      final articles = await _repository.fetchNews(
          category: state.selectedCategory,
          query: state.searchQuery
      );
      emit(state.copyWith(
        status: NewsStatus.loaded,
        articles: articles,
        errorMessage: null,
      ));
    } catch (e) {
      final localResults = await searchLocal(state.searchQuery);

      emit(state.copyWith(
          status: NewsStatus.loaded,
          articles: localResults,
          errorMessage: localResults.isEmpty
              ? 'Remote search failed. No local results found.'
              : 'Remote search failed. Displaying local cache results.'
      ));
    }
  }

  Future<List<ArticleModel>> searchLocal(String query) async {
    final results = await _repository.searchLocally(query);

    emit(state.copyWith(
      articles: results,
      status: NewsStatus.loaded,
      errorMessage: results.isEmpty && query.isNotEmpty ? 'No Results Found' : null,
    ));
    return results;
  }

  void applyCategoryFilter(String category) {
    emit(state.copyWith(
      selectedCategory: category,
      searchQuery: '',
      errorMessage: null,
    ));
    loadNews();
  }

  void clearSearch() {
    emit(state.copyWith(searchQuery: '', errorMessage: null));
    searchLocal('');
  }


}
