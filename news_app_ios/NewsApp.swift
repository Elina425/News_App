import SwiftUI

// MARK: - Dependency Setup

// 1. Data Layer setup
let apiService = NewsAPIService()
let newsRepository = NewsRepository(apiService: apiService)

// 2. Domain Layer setup
let getHeadlinesUseCase = GetTopHeadlinesUseCase(repository: newsRepository)

// 3. Presentation Layer setup (The root ViewModel is created with its dependencies)
let initialViewModel = NewsListViewModel(getHeadlinesUseCase: getHeadlinesUseCase)


// MARK: - App Entry Point

@main
struct NewsApp: App {
    var body: some Scene {
        WindowGroup {
            NewsListView(viewModel: initialViewModel)
        }
    }
}


