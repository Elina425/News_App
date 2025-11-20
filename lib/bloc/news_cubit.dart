import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repository/news_repository.dart';
import 'news_state.dart';

class NewsCubit extends Cubit<NewsState> {
  final NewsRepository _repository;

  NewsCubit(this._repository) : super(const NewsState());

  Future<void> loadNews() async {
    // Only show loading indicator if list is empty (initial load)
    if (state.articles.isEmpty) {
      emit(state.copyWith(status: NewsStatus.loading, errorMessage: null));
    }

    try {
      final articles = await _repository.fetchTopHeadlines();

      emit(state.copyWith(
        status: NewsStatus.loaded,
        articles: articles,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NewsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
