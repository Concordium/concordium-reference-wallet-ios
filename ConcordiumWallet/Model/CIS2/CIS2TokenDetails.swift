



import Foundation


struct CIS2TokenDetails: Codable, Hashable {
    let name: String
    let symbol: String?
    let decimals: Int
    let description: String
    let thumbnail, display: URL?
    let unique: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
        self.decimals = try container.decode(Int.self, forKey: .decimals)
        self.description = try container.decode(String.self, forKey: .description)
        self.thumbnail = try container.decodeIfPresent(URL.self, forKey: .thumbnail)
        self.display = try container.decodeIfPresent(URL.self, forKey: .display)
        self.unique = try container.decode(Bool.self, forKey: .unique)
    }
}
