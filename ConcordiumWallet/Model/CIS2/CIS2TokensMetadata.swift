import Foundation

/// Response object for wallet-proxy path: `v0/CIS2TokenMetadata/{contractIndex}/{contactSubindex}`
struct CIS2TokensMetadata: Codable {
    var contractName: String
    var metadata: [CIS2TokensMetadataItem]
}
