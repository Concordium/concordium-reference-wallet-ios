import Foundation

struct CIS2TokenSelectionRepresentable: Hashable {
    var tokenId: String
    var balance: Int
    var isSelected = false
    var details: CIS2TokenMetadataDetails
}
