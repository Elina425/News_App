import Foundation

final class NewsResponseMapper {
    
    /**
     Maps the raw Decodable Article array received from the API into
     the clean Domain Article entity array.
     
     - Parameter apiArticles: The array of Article structs as decoded directly from the API.
     - Parameter category: The category used in the request, attached for local search purposes (Part 2).
     - Returns: An array of Domain Article entities.
     */
    static func map(apiArticles: [Article], for category: NewsCategory?) -> [Article] {
        return apiArticles.map { article in
            let domainArticle = Article(
                // FIX: Add 'source:' label for the first argument
                source: article.source,
                author: article.author,
                title: article.title,
                description: article.description,
                url: article.url,
                urlToImage: article.urlToImage,
                publishedAt: article.publishedAt,
                content: article.content,
                currentCategory: category
            )
            return domainArticle
        }
    }
}
