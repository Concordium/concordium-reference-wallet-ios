import Foundation

struct CIS2TokensInfo: Codable {
    let count: Int
    let limit: Int
    let tokens: [CIS2Token]
}
