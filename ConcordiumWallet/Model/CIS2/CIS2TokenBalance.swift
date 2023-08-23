import Foundation

/// Response array returned for wallet-proxy path: `v0/CIS2TokenBalance/{contractIndex}/{contractSubindex}`
// MARK: - CIS2TokenBalance
struct CIS2TokenBalance: Codable {
    let balance, tokenId: String
}
