// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let bakerPoolResponse = try BakerPoolResponse(json)

import Foundation

// MARK: - BakerPoolResponse
struct BakerPoolResponse: Codable {
    let poolType: String
    let bakerID: Int
    let bakerEquityCapital: String
    let delegatedCapitalCap: String
    let poolInfo: PoolInfo
    let bakerStakePendingChange: BakerStakePendingChange
    let bakerAddress: String
    let delegatedCapital: String
    let currentPaydayStatus: CurrentPaydayStatus?

    enum CodingKeys: String, CodingKey {
        case poolType = "poolType"
        case bakerID = "bakerId"
        case bakerEquityCapital = "bakerEquityCapital"
        case delegatedCapitalCap = "delegatedCapitalCap"
        case poolInfo = "poolInfo"
        case bakerStakePendingChange = "bakerStakePendingChange"
        case bakerAddress = "bakerAddress"
        case delegatedCapital = "delegatedCapital"
        case currentPaydayStatus = "currentPaydayStatus"
    }
}

// MARK: BakerPoolResponse convenience initializers and mutators

extension BakerPoolResponse {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(BakerPoolResponse.self, from: data)
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
        poolType: String? = nil,
        bakerID: Int? = nil,
        bakerEquityCapital: String? = nil,
        delegatedCapitalCap: String? = nil,
        poolInfo: PoolInfo? = nil,
        bakerStakePendingChange: BakerStakePendingChange? = nil,
        bakerAddress: String? = nil,
        delegatedCapital: String? = nil,
        currentPaydayStatus: CurrentPaydayStatus?? = nil
    ) -> BakerPoolResponse {
        return BakerPoolResponse(
            poolType: poolType ?? self.poolType,
            bakerID: bakerID ?? self.bakerID,
            bakerEquityCapital: bakerEquityCapital ?? self.bakerEquityCapital,
            delegatedCapitalCap: delegatedCapitalCap ?? self.delegatedCapitalCap,
            poolInfo: poolInfo ?? self.poolInfo,
            bakerStakePendingChange: bakerStakePendingChange ?? self.bakerStakePendingChange,
            bakerAddress: bakerAddress ?? self.bakerAddress,
            delegatedCapital: delegatedCapital ?? self.delegatedCapital,
            currentPaydayStatus: currentPaydayStatus ?? self.currentPaydayStatus
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
