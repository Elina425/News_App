import Foundation

final class GetTopHeadlinesUseCase {
    private let repository: NewsRepositoryProtocol
    
    init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String? = nil, category: NewsCategory? = nil) async throws -> [Article] {
        let actualCategory = category == .all ? nil : category
        
        return try await repository.fetchArticles(query: query, category: actualCategory)
    }
}

