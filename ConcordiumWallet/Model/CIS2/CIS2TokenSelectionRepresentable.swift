import Foundation
import RealmSwift

struct CIS2TokenSelectionRepresentable: Hashable {
    let tokenId: String
    let balance: Int
    let contractIndex: String
    let name: String
    let symbol: String?
    let decimals: Int?
    let description: String
    let thumbnail: URL?
    let unique: Bool?
    let accountAddress: String

    var balanceDisplayValue: String {
        (unique ?? false) ? balance > 0 ? "Owned" : " Not owned" : GTU(intValue: balance).displayValue()
    }
}

/// The TokenOwnership object represents the ownership relationship between an Account, a Token, and a specific contract index within that account's holdings.
class CIS2TokenOwnershipEntity: Object {
    @Persisted var name: String = ""
    @Persisted var tokenId: String = ""
    @Persisted var symbol: String? = nil
    @Persisted var accountAddress: String = ""
    @Persisted var contractIndex: String = ""
    @Persisted var balance: Int = 0
    @Persisted var thumbnail: String? = nil
    @Persisted var unique: Bool? = nil
    @Persisted var tokenDescription: String = ""
    @Persisted var decimals: Int? = nil

    convenience init(
        with token: CIS2TokenSelectionRepresentable
    ) {
        self.init()
        name = token.name
        tokenId = token.tokenId
        symbol = token.symbol
        accountAddress = token.accountAddress
        contractIndex = token.contractIndex
        balance = token.balance
        unique = token.unique
        tokenDescription = token.description
        thumbnail = token.thumbnail?.absoluteString ?? nil
        decimals = token.decimals
    }

    func asRepresentable() -> CIS2TokenSelectionRepresentable {
        .init(
            tokenId: tokenId,
            balance: balance,
            contractIndex: contractIndex,
            name: name,
            symbol: symbol,
            decimals: decimals,
            description: tokenDescription,
            thumbnail: URL(string: thumbnail ?? "") ?? nil,
            unique: unique,
            accountAddress: accountAddress
        )
    }
}
