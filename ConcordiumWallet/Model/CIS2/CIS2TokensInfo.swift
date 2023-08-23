import Foundation

/// Response object for wallet-proxy path: `v0/CIS2Tokens/{contractIndex}/{contractSubindex}`
struct CIS2TokensInfo: Codable {
    let count: Int
    let limit: Int
    let tokens: [CIS2Token]
}
