import SwiftUI

struct NewsListView: View {
    @StateObject var viewModel: NewsListViewModel
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                HStack {
                    SearchTextField(text: $viewModel.searchText, action: {
                        Task { await viewModel.performSearch() }
                    })
                    
                    Button {
                        showingFilterSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .imageScale(.large)
                            .padding(.horizontal, 8)
                    }
                }
                .padding([.horizontal, .bottom]) // Padding only around the search/filter bar
                
                if viewModel.isLoading {
                    ProgressView("Loading News...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.articles.isEmpty {
                    VStack {
                        if viewModel.errorMessage == "No Results Found" {
                            Text("No Results Found")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        } else if let error = viewModel.errorMessage {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.articles) { article in
                            NavigationLink(destination: ArticleDetailView(article: article)) {
                                ArticleRowView(article: article)
                            }
                        }
                    }
                    .listStyle(.plain) // Use .plain to prevent excessive background/padding styles
                    .refreshable {
                        await viewModel.loadArticles(isRefresh: true)
                    }
                }
            }
            .navigationTitle("News")
            .onAppear {
                Task { await viewModel.loadArticles() }
            }
            .sheet(isPresented: $showingFilterSheet) {
                FilterView(
                    selectedCategory: $viewModel.selectedCategory,
                    applyAction: {
                        Task {
                            showingFilterSheet = false
                            await viewModel.applyFilter()
                        }
                    }
                )
            }
        }
    }
}
