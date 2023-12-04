import BigInt
import Foundation
import RealmSwift
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

    func toEntity() -> CIS2TokenOwnershipEntity {
        .init(with: self)
    }

    var balanceDisplayValue: String {
        if unique {
            return balance > BigInt.zero ? "Owned" : " Not owned"
        } else {
            return balance.format(implicitDecimals: decimals, minDecimals: 3)
        }
    }
    
    init(contractName: String, tokenId: String, balance: BigInt, contractIndex: String, name: String, symbol: String?, decimals: Int, description: String, thumbnail: URL?, unique: Bool, accountAddress: String) {
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
    }
}

extension BigInt {
    /// Formats the `BigInt` with a specified number of implicit decimals and a minimum number of decimals.
    ///
    /// - Parameters:
    ///   - implicitDecimals: The number of implicit decimals that the input number is expected to have..
    ///   - minDecimals: The minimum number of decimals to include in the formatted string. Defaults to 3.
    /// - Returns: A string representation of the formatted `BigInt`.
    func format(implicitDecimals: Int, minDecimals: Int = 3) -> String {
        var val = self
        var decimals = implicitDecimals
        while decimals > minDecimals && val % 10 == 0 {
            val /= 10
            decimals -= 1
        }
        return val.format(implicitDecimals: decimals)
    }
    
    func format(implicitDecimals: Int) -> String {
        
        if implicitDecimals == 0 {
            return String(self)
        }
        var val = self
        var sign = ""
        if val < 0 {
            val = abs(val)
            sign = "-"
        }
        let decimalSeparator = NumberFormatter().decimalSeparator!
        let divisor = BigInt(10).power(implicitDecimals)
        let int = String(val / divisor)
        let frac = String(val % divisor)
        let padding = String(repeating: "0", count: implicitDecimals - frac.count)
        
        return "\(sign)\(int)\(decimalSeparator)\(padding)\(frac)"
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
