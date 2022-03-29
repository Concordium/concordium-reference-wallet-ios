// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let accountBaker = try AccountBaker(json)

import Foundation

// MARK: - AccountBaker
struct AccountBaker: Codable {
    let bakerID: Int
    let stakedAmount: String
    let restakeEarnings: Bool
    let bakerAggregationVerifyKey: String
    let bakerElectionVerifyKey: String
    let bakerSignatureVerifyKey: String
    let pendingChange: PendingChange?

    enum CodingKeys: String, CodingKey {
        case bakerID = "bakerId"
        case stakedAmount = "stakedAmount"
        case restakeEarnings = "restakeEarnings"
        case bakerAggregationVerifyKey = "bakerAggregationVerifyKey"
        case bakerElectionVerifyKey = "bakerElectionVerifyKey"
        case bakerSignatureVerifyKey = "bakerSignatureVerifyKey"
        case pendingChange = "pendingChange"
    }
}

// MARK: AccountBaker convenience initializers and mutators

extension AccountBaker {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(AccountBaker.self, from: data)
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
        bakerID: Int? = nil,
        stakedAmount: String? = nil,
        restakeEarnings: Bool? = nil,
        bakerAggregationVerifyKey: String? = nil,
        bakerElectionVerifyKey: String? = nil,
        bakerSignatureVerifyKey: String? = nil,
        pendingChange: PendingChange?? = nil
    ) -> AccountBaker {
        return AccountBaker(
            bakerID: bakerID ?? self.bakerID,
            stakedAmount: stakedAmount ?? self.stakedAmount,
            restakeEarnings: restakeEarnings ?? self.restakeEarnings,
            bakerAggregationVerifyKey: bakerAggregationVerifyKey ?? self.bakerAggregationVerifyKey,
            bakerElectionVerifyKey: bakerElectionVerifyKey ?? self.bakerElectionVerifyKey,
            bakerSignatureVerifyKey: bakerSignatureVerifyKey ?? self.bakerSignatureVerifyKey,
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
