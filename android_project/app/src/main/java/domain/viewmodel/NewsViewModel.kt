package domain.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import data.repository.NewsApiRepository
import domain.models.Article
import domain.models.ResultState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch


class NewsViewModel(private val repository: NewsApiRepository = NewsApiRepository()) : ViewModel() {

    // UI State for the list of articles
    private val _newsState = MutableStateFlow<ResultState<List<Article>>>(ResultState.Loading)
    val newsState: StateFlow<ResultState<List<Article>>> = _newsState

    // State for Pull-to-Refresh Indicator
    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing: StateFlow<Boolean> = _isRefreshing

    init {
        loadNews()
    }

    fun loadNews(isRefresh: Boolean = false) {
        // Prevent simultaneous network calls unless explicitly refreshing
        if (_newsState.value is ResultState.Loading && !isRefresh) return

        viewModelScope.launch {
            if (isRefresh) {
                _isRefreshing.value = true
            } else {
                _newsState.value = ResultState.Loading
            }

            try {
                val articles = repository.fetchTopHeadlines()
                _newsState.value = ResultState.Success(articles)
            } catch (e: Exception) {
                _newsState.value = ResultState.Error(e.message ?: "An unknown error occurred.")
            } finally {
                _isRefreshing.value = false
            }
        }
    }
}