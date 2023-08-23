import Foundation

struct CIS2TokenDetails: Codable, Hashable {
    let name: String
    let symbol: String?
    let decimals: Int
    let description: String
    let thumbnail: ImageData?
    let unique: Bool
    struct ImageData: Codable, Hashable {
        let url: URL?
    }
}
