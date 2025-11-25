import Foundation

// MARK: - API Response Wrapper

struct NewsAPIResponse: Decodable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

final class NewsAPIService {
    private let apiKey = "d07eacefa48b49f99c32f234069a0aa1"
    private let baseURL = "https://newsapi.org/v2/top-headlines"

    func fetchArticles(query: String? = nil, category: NewsCategory? = nil) async throws -> [Article] {
        var components = URLComponents(string: baseURL)
        
        var parameters: [String: String] = [
            "apiKey": apiKey,
            "country": "us" 
        ]
        
        if let q = query, !q.isEmpty { parameters["q"] = q } // Part 2: Search
        if let cat = category { parameters["category"] = cat.rawValue } // Part 2: Filter
        
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components?.url else {
            throw NewsAPIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw NewsAPIError.invalidResponse
            }
            
            let apiResponse = try JSONDecoder().decode(NewsAPIResponse.self, from: data)
            
            // Associate the filter category for Part 2 local search/cache logic
            let fetchedArticles = apiResponse.articles.map { article in
                var mutableArticle = article
                mutableArticle.currentCategory = category
                return mutableArticle
            }
            
            return fetchedArticles
            
        } catch let decodingError as DecodingError {
            print("Decoding Error: \(decodingError)")
            throw NewsAPIError.decodingError(decodingError)
        } catch {
            print("Network Error: \(error)")
            throw NewsAPIError.networkError(error)
        }
    }
}
