// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let rewardParameters = try RewardParameters(json)

import Foundation

// MARK: - RewardParameters
struct RewardParameters: Codable {
    let mintDistribution: MintDistribution
    let transactionFeeDistribution: TransactionFeeDistribution
    let gASRewards: GASRewards

    enum CodingKeys: String, CodingKey {
        case mintDistribution = "mintDistribution"
        case transactionFeeDistribution = "transactionFeeDistribution"
        case gASRewards = "gASRewards"
    }
}

// MARK: RewardParameters convenience initializers and mutators

extension RewardParameters {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(RewardParameters.self, from: data)
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
        mintDistribution: MintDistribution? = nil,
        transactionFeeDistribution: TransactionFeeDistribution? = nil,
        gASRewards: GASRewards? = nil
    ) -> RewardParameters {
        return RewardParameters(
            mintDistribution: mintDistribution ?? self.mintDistribution,
            transactionFeeDistribution: transactionFeeDistribution ?? self.transactionFeeDistribution,
            gASRewards: gASRewards ?? self.gASRewards
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
