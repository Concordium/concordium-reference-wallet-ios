import Foundation

/// Part of response object for wallet-proxy path: `v0/CIS2TokenMetadata/{contractIndex}/{contactSubindex}`
/// - SeeAlso: ``CIS2TokensMetadata``
struct CIS2TokensMetadataItem: Codable {
    var metadataChecksum: String?
    var metadataURL: String
    var tokenId: String
}
