import SwiftUI

struct ArticleRowView: View {
    let article: Article
    
    var body: some View {
        HStack(alignment: .top) {
            AsyncImage(url: URL(string: article.urlToImage ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    // Placeholder (as shown in requirements images)
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(article.author ?? article.source?.name ?? "Unknown Source")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let category = article.currentCategory, category != .all {
                     Text(category.rawValue.capitalized)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .background(Color.blue)
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

