package data.repository

import data.models.NewsApiResponse
import domain.models.Article
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.engine.android.Android
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.get
import io.ktor.client.statement.HttpResponse
import io.ktor.serialization.kotlinx.json.json
import kotlinx.serialization.json.Json
import java.util.concurrent.ConcurrentHashMap

class NewsRepository {
    // 1. IMPORTANT: Replace this with your actual key
    private val apiKey = "d07eacefa48b49f99c32f234069a0aa1"
    private val baseUrl = "https://newsapi.org/v2/top-headlines"

    // PART 2: In-Memory Cache for offline/instant search
    private val cachedArticles: ConcurrentHashMap<String, Article> = ConcurrentHashMap()

    // Ktor Client setup
    private val httpClient = HttpClient(Android){
        install(ContentNegotiation){
            json(Json {
                ignoreUnknownKeys = true
            })
        }
    }

    suspend fun fetchTopHeadlines(): List<Article> {
        return fetchNews(category = "general", query = "")
    }

    // PART 1/2: Core Network Fetch (handles category and search query)
    suspend fun fetchNews(category: String, query: String): List<Article> {
        // Construct the URL with optional category and query parameters
        val categoryParam = if (category.isNotBlank()) "category=${category.lowercase()}&" else ""
        val queryParam = if (query.isNotBlank()) "q=$query&" else ""

        // Add language/country for quality and API key
        val url = "$baseUrl?${categoryParam}${queryParam}country=us&language=en&pageSize=50&apiKey=$apiKey"

        if (apiKey.isEmpty() || apiKey == "d07eacefa48b49f99c32f234069a0aa1") {
            throw Exception("API Key is missing or invalid. Please update.") // 👈 API Key Warning
        }

        try {
            val response: HttpResponse = httpClient.get(url)

            if (response.status.value == 200) {
                val apiResponse = response.body<NewsApiResponse>()

                val articles = apiResponse.articles.map { articleResponse ->
                    Article(
                        title = articleResponse.title ?: "No Title",
                        sourceName = articleResponse.source?.name ?: "Primary News Source",
                        author = articleResponse.author ?: "Editorial Team",
                        urlToImage = articleResponse.urlToImage,
                        description = articleResponse.description ?: "",
                        content = articleResponse.content ?: "Click to read more.",
                        category = category.ifBlank { "General" } // Use the requested category
                    ).also { article ->
                        // Cache the article using its title as a key (simple approach)
                        cachedArticles[article.title] = article
                    }
                }
                return articles
            } else {
                throw Exception("HTTP Error: ${response.status.value}. Check API response for details.")
            }
        } catch (e: Exception) {
            throw Exception("Network error: ${e.message ?: "Unknown"}")
        }
    }

    // PART 2: Local Search implementation against the cache (NOW ACCEPTS CATEGORY)
    fun searchLocally(query: String, category: String = ""): List<Article> { // 👈 FIX: ADD category parameter
        val allCached = cachedArticles.values.toList()

        // 1. Filter by category first, if a category is selected
        val categoryFiltered = if (category.isNotBlank() && category != "General") {
            allCached.filter {
                // Ensure the cached article's category matches the requested one
                it.category.equals(category, ignoreCase = true)
            }
        } else {
            allCached // Return all if no category is specified
        }

        // 2. Apply search query filtering (if any) to the category-filtered list
        if (query.isBlank()) {
            return categoryFiltered
        }

        val lowerCaseQuery = query.lowercase()

        // Filter the category-filtered list based on title, description, or content
        return categoryFiltered.filter { article ->
            article.title.lowercase().contains(lowerCaseQuery) ||
                    article.description.lowercase().contains(lowerCaseQuery) ||
                    article.content.lowercase().contains(lowerCaseQuery) ||
                    article.sourceName.lowercase().contains(lowerCaseQuery)
        }.toList()
    }
}