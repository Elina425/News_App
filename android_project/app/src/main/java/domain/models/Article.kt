package domain.models

data class Article(
    val title: String,
    val sourceName: String,
    val author: String,
    val urlToImage: String?,
    val description: String,
    val content: String,
    val category: String
)

// Data State for the Repository response (Part of Domain/ViewModel)
sealed class ResultState<out T> {
    object Loading : ResultState<Nothing>()
    data class Success<T>(val data: T) : ResultState<T>()
    data class Error(val message: String) : ResultState<Nothing>()
}