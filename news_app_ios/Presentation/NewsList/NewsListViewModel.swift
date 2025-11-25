import Foundation
import Combine

final class NewsListViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedCategory: NewsCategory = .all
    
    private var cachedArticles: [Article] = []
    
    private let getHeadlinesUseCase: GetTopHeadlinesUseCase
    
    init(getHeadlinesUseCase: GetTopHeadlinesUseCase) {
        self.getHeadlinesUseCase = getHeadlinesUseCase
    }
    
    // MARK: - API & Refresh (Part 1 & Pull to Refresh)
    
    @MainActor
    func loadArticles(isRefresh: Bool = false) async {
        isLoading = true
        errorMessage = nil
        
        // Use a basic assumption for offline check for the demo
        let isOnline = true
        
        if isOnline {
            do {
                let newArticles = try await getHeadlinesUseCase.execute(
                    query: isRefresh ? searchText : nil, // Only use search query if explicitly refreshing/searching
                    category: selectedCategory
                )
                
                self.articles = newArticles
                self.cachedArticles = newArticles
            } catch {
                self.errorMessage = "Failed to load news: \(error.localizedDescription)"
                // Fallback to cached data on API failure
                if self.articles.isEmpty { self.articles = cachedArticles }
            }
        } else {
            // Part 2: Offline scenario
            self.articles = cachedArticles
            self.errorMessage = "You are currently offline. Showing cached results."
        }
        
        isLoading = false
    }
    
    // MARK: - Search (Part 2)
    
    @MainActor
    func performSearch() async {
        guard !searchText.isEmpty else {
            // If text is cleared, reload with current category filter
            await loadArticles()
            return
        }
        
        let isOnline = true
        
        if isOnline {
            await loadArticles(isRefresh: true)
        } else {
            // Offline: Search locally on cached data (Part 2 requirement)
            let localResults = cachedArticles.filter { article in
                (article.title.localizedCaseInsensitiveContains(searchText) ||
                 (article.description?.localizedCaseInsensitiveContains(searchText) ?? false))
            }
            self.articles = localResults
            
            if articles.isEmpty {
                errorMessage = "No Results Found" // Part 2: No Results Found message
            }
        }
    }
    
    // MARK: - Filter (Part 2)
    
    @MainActor
    func applyFilter() async {
        await loadArticles()
    }
}

