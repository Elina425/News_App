import Foundation

final class NewsRepository: NewsRepositoryProtocol {
    private let apiService: NewsAPIService

    init(apiService: NewsAPIService) {
        self.apiService = apiService
    }

    func fetchArticles(query: String?, category: NewsCategory?) async throws -> [Article] {
        let apiArticles = try await apiService.fetchArticles(query: query, category: category)
        
        return NewsResponseMapper.map(apiArticles: apiArticles, for: category)
        
      
    }
}
