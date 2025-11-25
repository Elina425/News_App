
import Foundation

public struct Source: Decodable {
    let id: String?
    let name: String
}


// MARK: - Article Entity (Domain Model)

public struct Article: Decodable, Identifiable {
    public var id: String { url }
    
    let source: Source?
    let author: String?
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String
    let content: String?
    
    public var currentCategory: NewsCategory?
    
    
    enum CodingKeys: String, CodingKey {
        case source, author, title, description, url, urlToImage, publishedAt, content
    }
    public init(source: Source?,
                    author: String?,
                    title: String,
                    description: String?,
                    url: String,
                    urlToImage: String?,
                    publishedAt: String,
                    content: String?,
                    currentCategory: NewsCategory?) {
            self.source = source
            self.author = author
            self.title = title
            self.description = description
            self.url = url
            self.urlToImage = urlToImage
            self.publishedAt = publishedAt
            self.content = content
            self.currentCategory = currentCategory
        }
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.source = try container.decodeIfPresent(Source.self, forKey: .source)
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.url = try container.decode(String.self, forKey: .url)
        self.urlToImage = try container.decodeIfPresent(String.self, forKey: .urlToImage)
        self.publishedAt = try container.decode(String.self, forKey: .publishedAt)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        
        self.currentCategory = nil
    }
}
