package domain.models

data class Article(
    val title: String,
    val sourceName: String,
    val author: String,
    val urlToImage: String?
    // Part 2 will add description and content
)

// Data State for the Repository response (Part of Domain/ViewModel)
sealed class ResultState<out T> {
    object Loading : ResultState<Nothing>()
    data class Success<T>(val data: T) : ResultState<T>()
    data class Error(val message: String) : ResultState<Nothing>()
}