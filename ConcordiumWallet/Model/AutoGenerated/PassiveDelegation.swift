// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let passiveDelegation = try PassiveDelegation(json)

import Foundation

// MARK: - PassiveDelegation
struct PassiveDelegation: Codable {
    let commissionRates: CommissionRates
    let poolType: String
    let currentPaydayDelegatedCapital: String
    let allPoolTotalCapital: String
    let currentPaydayTransactionFeesEarned: String
    let delegatedCapital: String

    enum CodingKeys: String, CodingKey {
        case commissionRates = "commissionRates"
        case poolType = "poolType"
        case currentPaydayDelegatedCapital = "currentPaydayDelegatedCapital"
        case allPoolTotalCapital = "allPoolTotalCapital"
        case currentPaydayTransactionFeesEarned = "currentPaydayTransactionFeesEarned"
        case delegatedCapital = "delegatedCapital"
    }
}

// MARK: PassiveDelegation convenience initializers and mutators

extension PassiveDelegation {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PassiveDelegation.self, from: data)
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
        commissionRates: CommissionRates? = nil,
        poolType: String? = nil,
        currentPaydayDelegatedCapital: String? = nil,
        allPoolTotalCapital: String? = nil,
        currentPaydayTransactionFeesEarned: String? = nil,
        delegatedCapital: String? = nil
    ) -> PassiveDelegation {
        return PassiveDelegation(
            commissionRates: commissionRates ?? self.commissionRates,
            poolType: poolType ?? self.poolType,
            currentPaydayDelegatedCapital: currentPaydayDelegatedCapital ?? self.currentPaydayDelegatedCapital,
            allPoolTotalCapital: allPoolTotalCapital ?? self.allPoolTotalCapital,
            currentPaydayTransactionFeesEarned: currentPaydayTransactionFeesEarned ?? self.currentPaydayTransactionFeesEarned,
            delegatedCapital: delegatedCapital ?? self.delegatedCapital
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
