// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let balance = try Balance(json)

import Foundation

// MARK: - Balance
struct Balance: Codable {
    let accountAmount: String?
    let accountNonce: Int?
    let accountEncryptedAmount: AccountEncryptedAmount?
    let accountReleaseSchedule: AccountReleaseSchedule?
    let accountIndex: Int
    let accountBaker: AccountBaker?
    let accountDelegation: AccountDelegation?

    enum CodingKeys: String, CodingKey {
        case accountAmount = "accountAmount"
        case accountNonce = "accountNonce"
        case accountEncryptedAmount = "accountEncryptedAmount"
        case accountReleaseSchedule = "accountReleaseSchedule"
        case accountIndex = "accountIndex"
        case accountBaker = "accountBaker"
        case accountDelegation = "accountDelegation"
    }
}

// MARK: Balance convenience initializers and mutators

extension Balance {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Balance.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        accountAmount: String?? = nil,
        accountNonce: Int?? = nil,
        accountEncryptedAmount: AccountEncryptedAmount?? = nil,
        accountReleaseSchedule: AccountReleaseSchedule?? = nil,
        accountIndex: Int? = nil,
        accountBaker: AccountBaker?? = nil,
        accountDelegation: AccountDelegation?? = nil
    ) -> Balance {
        return Balance(
            accountAmount: accountAmount ?? self.accountAmount,
            accountNonce: accountNonce ?? self.accountNonce,
            accountEncryptedAmount: accountEncryptedAmount ?? self.accountEncryptedAmount,
            accountReleaseSchedule: accountReleaseSchedule ?? self.accountReleaseSchedule,
            accountIndex: accountIndex ?? self.accountIndex,
            accountBaker: accountBaker ?? self.accountBaker,
            accountDelegation: accountDelegation ?? self.accountDelegation
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
