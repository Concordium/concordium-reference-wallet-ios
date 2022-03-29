// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accountDelegation = try AccountDelegation(json)

import Foundation

// MARK: - AccountDelegation
struct AccountDelegation: Codable {
    let stakedAmount: String
    let restakeEarnings: Bool
    let delegationTarget: DelegationTarget
    let pendingChange: PendingChange?

    enum CodingKeys: String, CodingKey {
        case stakedAmount = "stakedAmount"
        case restakeEarnings = "restakeEarnings"
        case delegationTarget = "delegationTarget"
        case pendingChange = "pendingChange"
    }
}

// MARK: AccountDelegation convenience initializers and mutators

extension AccountDelegation {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AccountDelegation.self, from: data)
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
        stakedAmount: String? = nil,
        restakeEarnings: Bool? = nil,
        delegationTarget: DelegationTarget? = nil,
        pendingChange: PendingChange?? = nil
    ) -> AccountDelegation {
        return AccountDelegation(
            stakedAmount: stakedAmount ?? self.stakedAmount,
            restakeEarnings: restakeEarnings ?? self.restakeEarnings,
            delegationTarget: delegationTarget ?? self.delegationTarget,
            pendingChange: pendingChange ?? self.pendingChange
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
