import Foundation

protocol NewsRepositoryProtocol {
    func fetchArticles(query: String?, category: NewsCategory?) async throws -> [Article]
}

