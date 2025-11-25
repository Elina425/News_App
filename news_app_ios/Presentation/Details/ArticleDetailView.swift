import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                AsyncImage(url: URL(string: article.urlToImage ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Color.gray.opacity(0.3)
                            .frame(height: 250)
                    }
                }
                
                Group {
                    // Part 2: Source and Author
                    VStack(alignment: .leading) {
                        Text("Source: **\(article.source?.name ?? "N/A")**")
                        Text("Author: **\(article.author ?? "N/A")**")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    Text(article.title)
                        .font(.largeTitle)
                        .bold()
                    
                    Text(article.content ?? article.description ?? "Content not fully available.")
                        .font(.body)
                }
                .padding(.horizontal)

            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

