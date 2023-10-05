import Foundation

/// Representation of of single token. Part of ``CIS2TokensInfo`` response.
/// - SeeAlso: ``CIS2TokensInfo``
struct CIS2Token: Codable {
    let id: Int
    let token, totalSupply: String
}
