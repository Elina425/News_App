package data.repository

import android.net.http.HttpResponseCache.install
import com.google.firebase.crashlytics.buildtools.reloc.org.apache.http.client.HttpClient
import data.models.NewsApiResponse
import domain.models.Article
import io.ktor.client.call.body
import io.ktor.client.engine.android.Android
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.get
import io.ktor.client.statement.HttpResponse
import io.ktor.serialization.kotlinx.json.json

import kotlinx.serialization.json.Json

class NewsApiRepository {
    // 1. IMPORTANT: Replace this with your actual key
    private val apiKey = "YOUR_API_KEY_HERE"
    private val baseUrl = "https://newsapi.org/v2/top-headlines"

    // Ktor Client setup
    private val httpClient = io.ktor.client.HttpClient(Android){
        install(ContentNegotiation){
            json(Json {
                ignoreUnknownKeys = true
            })
        }
    }

    suspend fun fetchTopHeadlines(): List<Article> {
        // Added language and pageSize for quality, as previously discussed.
        val url = "$baseUrl?country=us&language=en&pageSize=50&apiKey=$apiKey"

        if (apiKey.isEmpty() || apiKey == "YOUR_API_KEY_HERE") {
            throw Exception("API Key is missing or invalid.")
        }

        try {
            val response: HttpResponse = httpClient.get(url)

            if (response.status.value == 200) {
                // Deserialize Ktor response body to the API model
                val apiResponse = response.body<NewsApiResponse>()

                // Map API model to Domain model (Article)
                return apiResponse.articles.map { articleResponse ->
                    Article(
                        title = articleResponse.title ?: "No Title",
                        sourceName = articleResponse.source?.name ?: "Primary News Source",
                        author = articleResponse.author ?: "Editorial Team",
                        urlToImage = articleResponse.urlToImage
                    )
                }
            } else {
                throw Exception("HTTP Error: ${response.status.value}")
            }
        } catch (e: Exception) {
            throw Exception("Network error: ${e.message ?: "Unknown"}")
        }
    }
}

