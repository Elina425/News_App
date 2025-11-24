package domain.viewmodel

import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import domain.models.Article
import domain.models.ResultState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import androidx.compose.runtime.State
import data.repository.NewsRepository
import io.ktor.client.statement.HttpResponse

class NewsViewModel(private val repository: NewsRepository = NewsRepository()) : ViewModel() {

    // UI State for the list of articles
    // PART 1: Core State Flow
    private val _newsState = MutableStateFlow<ResultState<List<Article>>>(ResultState.Loading)
    val newsState: StateFlow<ResultState<List<Article>>> = _newsState

    // PART 1: Pull-to-Refresh State
    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing: StateFlow<Boolean> = _isRefreshing

    // PART 2: Search and Filter States
    private val _searchQuery = mutableStateOf("")
    val searchQuery: State<String> = _searchQuery

    private val _selectedCategory = mutableStateOf("")
    val selectedCategory: State<String> = _selectedCategory

    private val _errorMessage = mutableStateOf<String?>(null)
    val errorMessage: State<String?> = _errorMessage

    // PART 2: Categories List
    val categories = listOf("Business", "Entertainment", "General", "Health")

    init {
        loadNews()
    }

    fun loadNews(isRefresh: Boolean = false) {
        if (_newsState.value is ResultState.Loading && !isRefresh) return

        viewModelScope.launch {
            if (isRefresh) {
                _isRefreshing.value = true
            } else {
                _newsState.value = ResultState.Loading
            }
            _errorMessage.value = null

            try {
                val articles = withContext(Dispatchers.IO) {
                    repository.fetchNews(category = _selectedCategory.value, query = "")
                }
                _newsState.value = ResultState.Success(articles)
            } catch (e: Exception) {
                val cachedArticles = repository.searchLocally(
                    query = _searchQuery.value,
                    category = _selectedCategory.value // 👈 Now correctly passes the category
                )
                _newsState.value = ResultState.Success(cachedArticles)
                _errorMessage.value = "Network Error. Showing cached data."
            } finally {
                _isRefreshing.value = false
            }
        }
    }


    fun applyCategoryFilter(category: String) {
        _selectedCategory.value = category
        _searchQuery.value = "" // Reset search when filtering
        loadNews() // Triggers remote fetch with new category
    }

    fun onSearchQueryChange(query: String) {
        _searchQuery.value = query

        // Perform instant local filtering
        val results = repository.searchLocally(query)
        _newsState.value = ResultState.Success(results)

        if (results.isNullOrEmpty() && query.isNotEmpty()) {
            _errorMessage.value = "No Results Found locally."
        } else {
            _errorMessage.value = null
        }
    }

    // PART 2: Remote Search (On button tap)
    fun remoteSearch() {
        if (_isRefreshing.value) return

        viewModelScope.launch {
            _isRefreshing.value = true
            _errorMessage.value = null

            try {
                val articles = withContext(Dispatchers.IO) {
                    repository.fetchNews(category = _selectedCategory.value, query = _searchQuery.value)
                }
                _newsState.value = ResultState.Success(articles)
                _errorMessage.value = null
            } catch (e: Exception) {
                // PART 2: If remote search fails, fallback to existing local search logic
                onSearchQueryChange(_searchQuery.value)
                _errorMessage.value = "Remote search failed. Displaying cached results."
            } finally {
                _isRefreshing.value = false
            }
        }
    }

    fun clearSearch() {
        _searchQuery.value = ""
        onSearchQueryChange("")
    }

    companion object {
        val Factory: androidx.lifecycle.ViewModelProvider.Factory =
            object : androidx.lifecycle.ViewModelProvider.Factory {
                @Suppress("UNCHECKED_CAST")
                override fun <T : ViewModel> create(modelClass: Class<T>): T {
                    return NewsViewModel(repository = NewsRepository()) as T
                }
            }
    }
}