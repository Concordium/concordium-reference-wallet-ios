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
            return balance.formatIntegerWithFractionDigits(fractionDigits: decimals)
        }
    }
}

extension BigInt {
    func formatIntegerWithFractionDigits(fractionDigits: Int) -> String {
        guard fractionDigits != 0 else { return "0" }
        // Convert the integer to a Double and divide by 10^fractionDigits to add the desired fraction
        let divisor = pow(10.0, Double(fractionDigits))
        let doubleValue = Double(self) / divisor
        
        // Use String(format:) to format the double as a string with the specified fraction digits
        let formatString = "%.\(fractionDigits)f"
        var formattedString = String(format: formatString, doubleValue)
        
        // Remove trailing zeros after the decimal point
        while formattedString.hasSuffix("0") {
            formattedString = String(formattedString.dropLast())
        }
        
        // Remove the decimal point if there are no digits after it
        if formattedString.hasSuffix(".") {
            formattedString = String(formattedString.dropLast())
        }
        
        return formattedString
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

    func asRepresentable() -> CIS2TokenSelectionRepresentable {
        .init(
            contractName: contractName,
            tokenId: tokenId,
            balance: .zero, // TODO: TAKE CARE OF IT SOON!!!!
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
