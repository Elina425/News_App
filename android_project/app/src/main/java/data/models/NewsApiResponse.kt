package data.models

import kotlinx.serialization.Serializable

// This models the overall API response structure
@Serializable
data class NewsApiResponse(
    val status: String,
    val totalResults: Int,
    val articles: List<ArticleResponse>
)

// This models the nested source object
@Serializable
data class SourceResponse(
    val id: String? = null,
    val name: String? = null
)

// This models the individual article from the API
@Serializable
data class ArticleResponse(
    val source: SourceResponse? = null,
    val author: String? = null,
    val title: String? = null,
    val description: String? = null,
    val url: String? = null,
    val urlToImage: String? = null,
    val publishedAt: String? = null,
    val content: String? = null
)