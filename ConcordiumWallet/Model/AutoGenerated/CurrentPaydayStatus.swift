// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let currentPaydayStatus = try CurrentPaydayStatus(json)

import Foundation

// MARK: - CurrentPaydayStatus
struct CurrentPaydayStatus: Codable {
    let finalizationLive: Bool
    let effectiveStake: String
    let transactionFeesEarned: String
    let bakerEquityCapital: String
    let lotteryPower: Double
    let blocksBaked: Int
    let delegatedCapital: String

    enum CodingKeys: String, CodingKey {
        case finalizationLive = "finalizationLive"
        case effectiveStake = "effectiveStake"
        case transactionFeesEarned = "transactionFeesEarned"
        case bakerEquityCapital = "bakerEquityCapital"
        case lotteryPower = "lotteryPower"
        case blocksBaked = "blocksBaked"
        case delegatedCapital = "delegatedCapital"
    }
}

// MARK: CurrentPaydayStatus convenience initializers and mutators

extension CurrentPaydayStatus {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(CurrentPaydayStatus.self, from: data)
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
        finalizationLive: Bool? = nil,
        effectiveStake: String? = nil,
        transactionFeesEarned: String? = nil,
        bakerEquityCapital: String? = nil,
        lotteryPower: Double? = nil,
        blocksBaked: Int? = nil,
        delegatedCapital: String? = nil
    ) -> CurrentPaydayStatus {
        return CurrentPaydayStatus(
            finalizationLive: finalizationLive ?? self.finalizationLive,
            effectiveStake: effectiveStake ?? self.effectiveStake,
            transactionFeesEarned: transactionFeesEarned ?? self.transactionFeesEarned,
            bakerEquityCapital: bakerEquityCapital ?? self.bakerEquityCapital,
            lotteryPower: lotteryPower ?? self.lotteryPower,
            blocksBaked: blocksBaked ?? self.blocksBaked,
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
