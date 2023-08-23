import Foundation

/// Response object containg detaile information about token metadata.
/// - Remark: Decoded as result for request to ``CIS2TokensMetadataItem.metadataURL``
struct CIS2TokenMetadataDetails: Codable, Hashable {
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
