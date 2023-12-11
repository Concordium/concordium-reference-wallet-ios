import BigInt
import Foundation
import RealmSwift

// sourcery: AutoMockable

struct CIS2TokenSelectionRepresentable: Hashable {
    let contractName: String
    let tokenId: String
    let balance: BigInt
    let contractIndex: String
    let name: String
    let symbol: String?
    let decimals: Int
    let description: String
    let thumbnail: URL?
    let unique: Bool
    let accountAddress: String
    let dateAdded: Date?
    func toEntity() -> CIS2TokenOwnershipEntity {
        .init(with: self)
    }

    var balanceDisplayValue: String {
        if unique {
            return balance > BigInt.zero ? "Owned" : " Not owned"
        } else {
            return FungibleToken(intValue: balance, decimals: decimals, symbol: symbol).formattedString(subunitPrecision: decimals, minDecimalDigits: 3)
        }
    }

    init(contractName: String, tokenId: String, balance: BigInt, contractIndex: String, name: String, symbol: String?, decimals: Int, description: String, thumbnail: URL?, unique: Bool, accountAddress: String, dateAdded: Date? = Date()) {
        self.contractName = contractName
        self.tokenId = tokenId
        self.balance = balance
        self.contractIndex = contractIndex
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.description = description
        self.thumbnail = thumbnail
        self.unique = unique
        self.accountAddress = accountAddress
        self.dateAdded = dateAdded
    }

    init(entity: CIS2TokenOwnershipEntity, tokenBalance: BigInt) {
        contractName = entity.contractName
        tokenId = entity.tokenId
        balance = tokenBalance
        contractIndex = entity.contractIndex
        name = entity.name
        symbol = entity.symbol
        decimals = entity.decimals
        description = entity.tokenDescription
        thumbnail = URL(string: entity.thumbnail ?? "") ?? nil
        unique = entity.unique
        accountAddress = entity.accountAddress
        dateAdded = entity.dateAdded.timeIntervalSince1970 > 0 ? entity.dateAdded : nil
    }
}

/// The TokenOwnership object represents the ownership relationship between an Account, a Token, and a specific contract index within that account's holdings.
class CIS2TokenOwnershipEntity: Object {
    @Persisted var name: String = ""
    @Persisted var contractName: String = ""
    @Persisted var tokenId: String = ""
    @Persisted var symbol: String? = nil
    @Persisted var accountAddress: String = ""
    @Persisted var contractIndex: String = ""
    @Persisted var thumbnail: String? = nil
    @Persisted var unique: Bool = false
    @Persisted var tokenDescription: String = ""
    @Persisted var decimals: Int = 0
    @Persisted var dateAdded: Date = Date()

    convenience init(
        with token: CIS2TokenSelectionRepresentable
    ) {
        self.init()
        name = token.name
        contractName = token.contractName
        tokenId = token.tokenId
        symbol = token.symbol
        accountAddress = token.accountAddress
        contractIndex = token.contractIndex
        unique = token.unique
        tokenDescription = token.description
        thumbnail = token.thumbnail?.absoluteString ?? nil
        decimals = token.decimals
    }
}

extension Array where Element == CIS2TokenSelectionRepresentable {
    /// Returns array of `CIS2TokenSelectionRepresentable` by date, showing the oldest on top.
    /// Because sorting has been implemented later then the storing feature, user might have elements in local storage without date property.
    /// Items without date are sorted alphabetically and showed on the bottom.
    func sorted() -> [CIS2TokenSelectionRepresentable] {
        sorted {
            switch ($0.dateAdded, $1.dateAdded) {
            // If both elements have a date, it sorts them based on the date.
            case let (.some(ldate), .some(rdate)):
                return ldate < rdate
            // If both elements have no date, it sorts them alphabetically.
            case (.none, .none):
                return $0.name < $1.name
            // If only the left element has a date, it places it above the right element.
            case (.some, .none):
                return true
            // If only the right element has a date, it places it below the left element.
            case (.none, .some):
                return false
            }
        }
    }
}
